import 'dart:async';

import 'package:choloto/ads/croix_ad_gate.dart';
import 'package:choloto/ads/draw_ad_eligibility.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const content = Text('content');
  Widget page(CroixAdGate gate,
          {String language = 'en', Brightness brightness = Brightness.light}) =>
      MaterialApp(
        theme: ThemeData(brightness: brightness),
        localizationsDelegates: const [
          FFLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FallbackMaterialLocalizationDelegate(),
          FallbackCupertinoLocalizationDelegate()
        ],
        supportedLocales: [Locale(language)],
        locale: Locale(language),
        home: gate,
      );

  testWidgets('an unresolved or VIP profile never requests a rewarded slot',
      (tester) async {
    final accounts = StreamController<DrawAdAccount>();
    final gate = CroixAdGate(
        accounts: () => accounts.stream,
        child: content,
        prepare: (_, __) => throw TestFailure('Unexpected ad request'));
    await tester.pumpWidget(page(gate));
    accounts.add((freeUid: null, checking: true));
    await tester.pump();
    expect(find.text('content'), findsNothing);
    accounts.add((freeUid: null, checking: false));
    await tester.pump();
    expect(find.text('content'), findsOneWidget);
    await accounts.close();
  });

  testWidgets(
      'closing the ad exits a direct link and the next visit requests a new slot',
      (tester) async {
    var requests = 0;
    late void Function(bool) close;
    final router = GoRouter(initialLocation: '/croix', routes: [
      GoRoute(path: '/', builder: (_, __) => const Text('home')),
      GoRoute(
          path: '/croix',
          builder: (_, __) => CroixAdGate(
                accounts: () =>
                    Stream.value((freeUid: 'free', checking: false)),
                prepare: (ready, done) {
                  requests++;
                  close = done;
                  ready(() {});
                  return () {};
                },
                child: content,
              )),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      localizationsDelegates: const [FFLocalizationsDelegate()],
      supportedLocales: const [Locale('en')],
      routerConfig: router,
    ));
    await tester.pumpAndSettle();
    close(false);
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
    expect(find.text('content'), findsNothing);
    router.push('/croix');
    await tester.pumpAndSettle();
    expect(requests, 2);
    close(true);
    await tester.pumpAndSettle();
    expect(find.text('content'), findsOneWidget);
  });

  for (final viewport in [const Size(320, 568), const Size(1280, 800)]) {
    for (final brightness in Brightness.values) {
      for (final language in FFLocalizations.languages()) {
        testWidgets(
            'opt-in and completion at ${viewport.width} in ${brightness.name} / $language',
            (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = viewport;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          late void Function(bool) finish;
          var views = 0;
          final gate = CroixAdGate(
            accounts: () => Stream.value((freeUid: 'free', checking: false)),
            prepare: (ready, done) {
              finish = done;
              ready(() => views++);
              return () {};
            },
            child: content,
          );
          await tester.pumpWidget(
              page(gate, language: language, brightness: brightness));
          await tester.pumpAndSettle();
          expect(find.text('content'), findsNothing);
          expect(views, 0);
          final label = FFLocalizations(Locale(language)).getVariableText(
            frText: 'Voir une pub pour ouvrir la Croix',
            enText: 'Watch an ad to open the Lucky Cross',
            crText: 'Gade yon piblisite pou ouvri Kwa Lachans',
          );
          await tester.tap(find.text(label));
          await tester.pump();
          expect(views, 1);
          expect(find.text('content'), findsNothing);
          finish(true);
          await tester.pump();
          expect(find.text('content'), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
