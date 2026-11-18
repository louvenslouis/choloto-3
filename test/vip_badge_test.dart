import 'dart:ui' as ui;

import 'package:choloto/accomplissements/member_vip_badge.dart';
import 'package:choloto/accomplissements/vip_badge.dart';
import 'package:choloto/flutter_flow/internationalization.dart';
import 'package:choloto/settings/profil/profil/profil_widget.dart';
import 'package:choloto/settings/upgrade/subscription_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime at(int day) => DateTime.utc(2028).add(Duration(days: day));

VerifiedVipTime daysOfVip(int days, {bool partial = false}) =>
    (elapsed: Duration(days: days), days: days, partial: partial);

SubscriptionTransaction event(
        int start, int? end, int? previous, int before, int after,
        {String type = 'subscription'}) =>
    SubscriptionTransaction.fromMap(id: '$start', data: {
      'created_at': at(start),
      if (end != null) 'new_end_sub': at(end),
      if (previous != null) 'previous_end_sub': at(previous),
      'transaction_type': type,
      'member_time_before': before,
      'member_time_after': after,
    });

VerifiedVipTime time(List<SubscriptionTransaction> receipts, int now,
        {int? expiry, required int count}) =>
    verifiedVipTime(
        history: receipts,
        expiry: expiry == null ? null : at(expiry),
        created: at(0),
        memberTime: count,
        onboarded: null,
        now: at(now));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all eight medal illustrations decode from the application bundle',
      () async {
    for (var rank = 1; rank <= defaultVipBadges.length; rank++) {
      final data =
          await rootBundle.load('assets/images/vip_badges/rank-$rank.webp');
      final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThanOrEqualTo(144));
      expect(frame.image.height, greaterThanOrEqualTo(144));
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('defaults, exact boundaries and custom thresholds', () {
    expect(readVipBadges(null), defaultVipBadges);
    final rows =
        defaultVipBadges.map((t) => {'name': t.name, 'days': t.days}).toList();
    for (var i = 0; i < rows.length; i++) {
      final t = defaultVipBadges[i];
      expect(
          vipBadgeIndex(defaultVipBadges, daysOfVip(t.days), active: true), i);
      if (i > 0) {
        expect(
            vipBadgeIndex(defaultVipBadges, daysOfVip(t.days - 1),
                active: true),
            i - 1);
      }
    }
    rows[1] = {'name': 'Club Soleil', 'days': 15};
    final tiers = readVipBadges({'tiers': rows});
    expect(tiers[vipBadgeIndex(tiers, daysOfVip(15), active: false)!].name,
        'Club Soleil');
    rows[1]['days'] = 0;
    expect(() => readVipBadges({'tiers': rows}), throwsFormatException);
  });

  test(
      'uses elapsed intervals for renewals, adjustments, cancellations and gaps',
      () {
    final first = event(1, 16, null, 0, 1);
    final renewal = event(10, 31, 16, 1, 2, type: 'renewal');
    expect(time([renewal, first], 20, expiry: 31, count: 2), daysOfVip(19));
    final cancellation = event(22, null, 31, 2, 2, type: 'cancellation');
    final compensation = event(50, 62, null, 2, 2, type: 'adjustment');
    final shortened = event(55, 60, 62, 2, 2, type: 'adjustment');
    expect(
        time([first, renewal, cancellation, compensation, shortened], 99,
            expiry: 60, count: 2),
        daysOfVip(31));
  });

  test('unknown or incomplete history awards only independently verified days',
      () {
    expect(time([], 90, count: 0), daysOfVip(0));
    expect(time([], 90, expiry: 100, count: 6), daysOfVip(0, partial: true));
    expect(
        time([event(8, 50, 5, 4, 5), event(51, 90, 45, 5, 6)], 95,
            expiry: 90, count: 6),
        daysOfVip(39, partial: true));
  });

  test('free accounts retain their rank only above 14 elapsed VIP days', () {
    for (final before in [0, 4]) {
      for (final offset in [-1, 0, 1]) {
        // Two separate periods of seven days; a legacy start may be missing.
        final expiry = at(24).add(Duration(milliseconds: offset));
        final second = SubscriptionTransaction.fromMap(id: 'b', data: {
          'created_at': at(17),
          'previous_end_sub': at(7),
          'new_end_sub': expiry,
          'member_time_before': before + 1,
          'member_time_after': before + 2,
        });
        final measured = verifiedVipTime(
            history: [event(0, 7, null, before, before + 1), second],
            expiry: expiry,
            memberTime: before + 2,
            created: at(0),
            onboarded: null,
            now: at(90));
        expect(measured.partial, before != 0);
        expect(measured.elapsed,
            const Duration(days: 14) + Duration(milliseconds: offset));
        expect(vipBadgeIndex(defaultVipBadges, measured, active: false),
            offset > 0 ? 0 : null);
      }
    }
    final unknown = time([], 90, expiry: 60, count: 6);
    expect(vipBadgeIndex(defaultVipBadges, unknown, active: false), isNull);
    expect(vipBadgeIndex(defaultVipBadges, unknown, active: true), 0);
  });

  test(
      'uses the current VIP expiry and excludes signup markers even with clock skew',
      () {
    bool active(DateTime? expiry, DateTime now) => hasActiveVipForBadge(
        expiry: expiry, created: at(2), onboarded: at(4), now: now);
    expect(active(null, at(0)), isFalse);
    expect(active(at(1), at(0)), isFalse);
    expect(active(at(2), at(0)), isFalse);
    expect(active(at(4), at(0)), isFalse);
    expect(active(at(5), at(0)), isTrue);
    expect(active(at(5), at(5)), isTrue);
    expect(active(at(5), at(5).add(const Duration(milliseconds: 1))), isFalse);
  });

  for (final size in [const Size(320, 640), const Size(1024, 768)]) {
    for (final brightness in Brightness.values) {
      for (final language in FFLocalizations.languages()) {
        testWidgets(
            'badge, progress and custom title ${size.width} ${brightness.name} $language',
            (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final locale = Locale(language);
          final tiers = [...defaultVipBadges];
          tiers[1] = (
            name: 'Membre exceptionnel des amis fidèles du club CHOLOTO',
            days: 21
          );
          Future<void> render(int days,
              {bool collection = true, bool active = false}) {
            final badges = VipBadgeView(
                tiers: tiers,
                time: daysOfVip(days),
                active: active,
                showCollection: collection);
            return tester.pumpWidget(MaterialApp(
              theme: ThemeData(brightness: brightness, useMaterial3: false),
              locale: locale,
              supportedLocales:
                  FFLocalizations.languages().map((l) => Locale(l)),
              localizationsDelegates: const [
                FFLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                FallbackMaterialLocalizationDelegate(),
                FallbackCupertinoLocalizationDelegate()
              ],
              home: Scaffold(
                  body: Center(
                      child: collection
                          ? badges
                          : ProfileAvatar(photoUrl: '', badge: badges))),
            ));
          }

          await render(21);
          await tester.pumpAndSettle();
          expect(find.byType(Image), findsNWidgets(8));
          expect(find.byType(ColorFiltered), findsNWidgets(2));
          expect(find.text(tiers[1].name), findsNothing);
          expect(find.byIcon(Icons.lock_rounded), findsNWidgets(6));
          expect(find.byIcon(Icons.check_rounded), findsOneWidget);
          final medals = find.byType(IconButton);
          expect(medals, findsNWidgets(8));
          for (var i = 0; i < tiers.length; i++) {
            final medal = find.byKey(ValueKey('vip-medal-${i + 1}'));
            expect(
                find.descendant(
                    of: medal, matching: find.byType(ColorFiltered)),
                i <= 1 ? findsOneWidget : findsNothing);
            expect(
                tester.getSize(medal).shortestSide, greaterThanOrEqualTo(48));
            expect(tester.getSemantics(medal).tooltip,
                contains(vipBadgeName(FFLocalizations(locale), tiers[i].name)));
            expect(
                tester.getSize(
                    find.descendant(of: medal, matching: find.byType(Image))),
                const Size.square(48));
          }
          final current = find.byKey(const ValueKey('vip-medal-2'));
          await tester.tap(current);
          await tester.pumpAndSettle();
          expect(find.text(tiers[1].name), findsOneWidget);
          final sheetFilter = find.descendant(
              of: find.byType(BottomSheet),
              matching: find.byType(ColorFiltered));
          expect(sheetFilter, findsOneWidget);
          await render(21, active: true);
          await tester.pumpAndSettle();
          expect(find.byType(ColorFiltered), findsNothing);
          expect(find.text(tiers[1].name), findsOneWidget);
          await render(21);
          await tester.pumpAndSettle();
          expect(sheetFilter, findsOneWidget);
          expect(find.textContaining('21 / 60'), findsOneWidget);
          expect(find.byType(LinearProgressIndicator), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('close-vip-medal')));
          await tester.pumpAndSettle();
          expect(find.text(tiers[1].name), findsNothing);
          await tester.tap(find.byKey(const ValueKey('vip-medal-8')));
          await tester.pumpAndSettle();
          expect(sheetFilter, findsNothing);
          expect(
              find.textContaining(
                  FFLocalizations(locale).getText('ach_locked')),
              findsOneWidget);
          expect(find.textContaining('21 / 1460'), findsOneWidget);
          await tester.tap(find.byKey(const ValueKey('close-vip-medal')));
          await tester.pumpAndSettle();
          await render(1460, collection: false);
          await tester.pumpAndSettle();
          expect(find.byType(Image), findsOneWidget);
          expect(find.byType(ColorFiltered), findsOneWidget);
          final portrait = tester.getRect(find.byIcon(Icons.location_history));
          final medal = tester.getRect(find.byType(Image));
          expect(medal.size, const Size.square(24));
          expect(medal.center.dx, greaterThan(portrait.center.dx));
          expect(medal.center.dy, lessThan(portrait.center.dy));
          expect(portrait.overlaps(medal), isTrue);
          expect(
              tester
                  .getSize(find.byKey(const ValueKey('vip-medal-8')))
                  .shortestSide,
              greaterThanOrEqualTo(48));
          await tester.tap(find.byKey(const ValueKey('vip-medal-8')));
          await tester.pumpAndSettle();
          expect(
              find.text(vipBadgeName(
                  FFLocalizations(locale), defaultVipBadges.last.name)),
              findsOneWidget);
          expect(find.byType(LinearProgressIndicator), findsNothing);
          expect(find.textContaining(RegExp('^1460 ')), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.byKey(const ValueKey('close-vip-medal')));
          await tester.pumpAndSettle();
          for (final collection in [true, false]) {
            await render(0, collection: collection);
            await tester.pumpAndSettle();
            expect(find.byType(IconButton), findsNothing);
            await render(14, active: true, collection: collection);
            await tester.tap(find.byKey(const ValueKey('vip-medal-1')));
            await tester.pumpAndSettle();
            expect(
                find.byKey(const ValueKey('close-vip-medal')), findsOneWidget);
            await render(14, collection: collection);
            await tester.pumpAndSettle();
            expect(find.byType(IconButton), findsNothing);
            expect(tester.getSize(find.byType(VipBadgeView)), Size.zero);
          }
        });
      }
    }
  }
}
