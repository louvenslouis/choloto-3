import 'dart:async';

import 'package:choloto/autres/bingo/bingo/bingo_reaction_button.dart';
import 'package:choloto/autres/bingo/bingo/bingo_reaction_service.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Total extends Fake implements AggregateQuerySnapshot {
  _Total(this.count);
  @override
  final int count;
}

class _Query extends Fake implements AggregateQuery {
  Future<AggregateQuerySnapshot> result = Future.value(_Total(42));
  @override
  Future<AggregateQuerySnapshot> get(
          {AggregateSource source = AggregateSource.server}) =>
      result;
}

// Test doubles isolate aggregation responses without a Firebase connection.
// ignore: subtype_of_sealed_class
class _Collection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _Collection(this.query);
  final _Query query;
  @override
  AggregateQuery count() => query;
}

// ignore: subtype_of_sealed_class
class _Bingo extends Fake implements DocumentReference<Map<String, dynamic>> {
  _Bingo(this.query);
  final _Query query;
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    expect(path, 'bingostats');
    return _Collection(query);
  }
}

void main() {
  testWidgets(
      'total refreshes on selection, removal and Bingo change; menu pauses and resumes',
      (tester) async {
    final query = _Query();
    final reference = _Bingo(query);
    var opened = 0;
    var closed = 0;
    BingoReaction? chosen;
    Future<void> show(
        {BingoReaction? selected, bool enabled = true, _Bingo? bingo}) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [FFLocalizationsDelegate()],
        home: Scaffold(
            body: BingoReactionButton(
          reference: bingo ?? reference,
          selectedReaction: selected,
          enabled: enabled,
          onReaction: (value) => chosen = value,
          onMenuOpened: () => opened++,
          onMenuClosed: () => closed++,
        )),
      ));
      await tester.pumpAndSettle();
    }

    await show();
    expect(find.text('42'), findsOneWidget);
    await tester.tap(find.byType(BingoReactionButton));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(chosen, isNull);
    await tester.tap(find.byKey(const ValueKey('bingo-story-like')));
    await tester.pumpAndSettle();
    expect(chosen, BingoReaction.positive);
    expect(closed, 1);
    query.result = Future.value(_Total(43));
    await show(selected: BingoReaction.positive);
    expect(find.text('43'), findsOneWidget);
    query.result = Future.value(_Total(42));
    await show();
    expect(find.text('42'), findsOneWidget);
    await show(enabled: false);
    await tester.tap(find.byType(BingoReactionButton));
    await tester.pumpAndSettle();
    expect(opened, 1);
    final nextQuery = _Query()..result = Future.value(_Total(7));
    await show(bingo: _Bingo(nextQuery));
    expect(find.text('7'), findsOneWidget);
    expect(find.text('42'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'loading and offline totals never claim zero; opening menu retries',
      (tester) async {
    final query = _Query();
    final pending = Completer<AggregateQuerySnapshot>();
    query.result = pending.future;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en')],
      localizationsDelegates: const [FFLocalizationsDelegate()],
      home: Scaffold(
          body: BingoReactionButton(
              reference: _Bingo(query), onReaction: (_) {})),
    ));
    expect(find.text('…'), findsOneWidget);
    pending.completeError(Exception('offline'));
    await tester.pumpAndSettle();
    expect(find.text('—'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    query.result = Future.value(_Total(0));
    await tester.tap(find.byType(BingoReactionButton));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.tapAt(const Offset(700, 500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bingo-story-like')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
