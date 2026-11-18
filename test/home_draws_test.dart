import 'dart:async';

import 'package:choloto/backend/schema/resultats_record.dart';
import 'package:choloto/components/tirages_home_widget.dart';
import 'package:choloto/components/vip_casino_card.dart';
import 'package:choloto/flutter_flow/flutter_flow_util.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_firestore.dart';

void main() {
  setUp(FFAppState.reset);

  Future<void> pumpDraws(WidgetTester tester, {String language = 'en'}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 700);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('cr')],
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FallbackMaterialLocalizationDelegate(),
        FallbackCupertinoLocalizationDelegate(),
      ],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.8),
        ),
        child: child!,
      ),
      home: const Scaffold(
          body: SingleChildScrollView(child: TiragesHomeWidget())),
    ));
    await tester.pump();
  }

  testWidgets(
      'both draws retain published values and optional Florida fourth number',
      (tester) async {
    ResultatsRecord record(String market, List<String> numbers) =>
        ResultatsRecord.getDocumentFromData({
          'tirage': market,
          'numeros': numbers,
          'periode': '09:49 PM',
          'date': DateTime(2026, 11, 17),
        }, MemoryReference('resultats/test-$market'));
    await FFAppState().newYorkTirage(
        requestFn: () async => [
              record('ny', ['007', '04'])
            ]);
    await FFAppState().floridaTirage(
        requestFn: () async => [
              record('fl', ['516', '09', '32', '0123'])
            ]);
    await pumpDraws(tester);
    expect(find.byType(VipCasinoChip), findsNWidgets(7));
    for (final number in ['007', '04', '-', '516', '09', '32', '0123']) {
      expect(find.text(number), findsOneWidget);
    }
    expect(find.text('09:49 PM · Nov 17'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  for (final (language, midday, evening) in [
    ('fr', 'Midi', 'Soir'),
    ('en', 'Midday', 'Evening'),
    ('cr', 'Midi', 'Aswè'),
  ]) {
    testWidgets('localizes historical draw periods in $language',
        (tester) async {
      ResultatsRecord record(String period, String market) =>
          ResultatsRecord.getDocumentFromData(
            {'periode': period, 'tirage': market},
            MemoryReference('resultats/test-$market'),
          );
      await FFAppState()
          .newYorkTirage(requestFn: () async => [record('MIDI', 'ny')]);
      await FFAppState()
          .floridaTirage(requestFn: () async => [record('sOiR', 'fl')]);
      await pumpDraws(tester, language: language);
      await tester.pumpAndSettle();
      expect(find.text(midday), findsOneWidget);
      expect(find.text(evening), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('each market independently shows empty, waiting and error states',
      (tester) async {
    await FFAppState().newYorkTirage(requestFn: () async => []);
    final pending = Completer<List<ResultatsRecord>>();
    FFAppState().floridaTirage(requestFn: () => pending.future);
    await pumpDraws(tester);
    expect(find.text('No results'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.completeError(StateError('test offline'));
    await tester.pump();
    expect(find.text('Results unavailable'), findsOneWidget);
    expect(find.text('No results'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(VipCasinoChip), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('short Haitian Creole result dates use the local abbreviated month', () {
    expect(dateTimeFormat('MMMd', DateTime(2026, 8, 7), locale: 'cr'), '7 out');
  });
}
