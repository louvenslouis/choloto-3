import 'dart:async';

import 'package:choloto/backend/schema/resultats_record.dart';
import 'package:choloto/components/tirages_home_widget.dart';
import 'package:choloto/flutter_flow/flutter_flow_util.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/memory_firestore.dart';

class _FixtureDrawsModel extends TiragesHomeModel {
  @override
  void loadDraws({bool refresh = false}) {}
}

void main() {
  setUp(FFAppState.reset);

  Future<void> pumpDraws(WidgetTester tester,
      {String language = 'en',
      TiragesHomeModel? model,
      bool reduceMotion = false,
      bool visible = true}) async {
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
          disableAnimations: reduceMotion,
        ),
        child: child!,
      ),
      home: Scaffold(
          body: SingleChildScrollView(
              child: TickerMode(
        enabled: visible,
        child: model == null
            ? const TiragesHomeWidget()
            : wrapWithModel<TiragesHomeModel>(
                model: model,
                updateCallback: () {},
                child: TiragesHomeWidget(key: ObjectKey(model)),
              ),
      ))),
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
    expect(find.byKey(const ValueKey('home-result-chip')), findsNWidgets(7));
    for (final number in ['007', '04', '-', '516', '09', '32', '0123']) {
      expect(find.text(number), findsOneWidget);
    }
    final dates = find.text('09:49 PM · Nov 17');
    expect(dates, findsNWidgets(2));
    // At 320px with enlarged text, the full date fits above the four chips.
    expect(tester.getBottomLeft(dates.last).dy,
        lessThan(tester.getTopLeft(find.text('0123')).dy));
    expect(tester.getTopRight(find.text('0123')).dx, lessThan(320));
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
    expect(find.byKey(const ValueKey('home-result-chip')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new draw chips settle once per market and honor reduced motion',
      (tester) async {
    ResultatsRecord draw(int day, String number) =>
        ResultatsRecord.getDocumentFromData(
          {
            'date': DateTime(2026, 11, day),
            'numeros': [number, '05', '07']
          },
          MemoryReference('resultats/latest'),
        );
    final model = _FixtureDrawsModel()
      ..newYork = Future.value([draw(16, '421')])
      ..florida = Future.value([]);
    Future<void> render({bool reduceMotion = false, bool visible = true}) =>
        pumpDraws(tester,
            model: model, reduceMotion: reduceMotion, visible: visible);
    Matrix4 motion(String number) => tester
        .widget<Transform>(find.ancestor(
          of: find.text(number).first,
          matching: find.byKey(const ValueKey('home-result-chip-motion')),
        ))
        .transform;

    await render();
    expect(motion('421').isIdentity(), isTrue);
    model.florida = Future.value([draw(17, '516')]);
    await render();
    expect(motion('516').isIdentity(), isFalse);
    expect(motion('421').isIdentity(), isTrue);
    await tester.pumpAndSettle();
    expect(motion('516').isIdentity(), isTrue);

    model.newYork = Future.value([draw(17, '427')]);
    await render();
    expect(motion('427').isIdentity(), isFalse);
    await tester.pump(const Duration(milliseconds: 150));
    expect(motion('427'), isNot(motion('05')));
    await tester.pumpAndSettle();
    model.newYork = Future.value([draw(17, '427')]);
    await render();
    expect(motion('427').isIdentity(), isTrue);
    await tester.pumpWidget(const SizedBox());
    await render();
    expect(motion('427').isIdentity(), isTrue);

    model.newYork = Future.value([draw(18, '001')]);
    await render(reduceMotion: true);
    expect(motion('001').isIdentity(), isTrue);
    model.newYork = Future.value([draw(19, '002')]);
    await render(visible: false);
    await render();
    expect(motion('002').isIdentity(), isTrue);
    expect(tester.takeException(), isNull);
  });

  test('short Haitian Creole result dates use the local abbreviated month', () {
    expect(dateTimeFormat('MMMd', DateTime(2026, 8, 7), locale: 'cr'), '7 out');
  });
}
