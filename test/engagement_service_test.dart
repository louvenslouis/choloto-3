import 'package:choloto/accomplissements/achievement_progress.dart';
import 'package:choloto/services/engagement_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/memory_firestore.dart';

void main() {
  group('daily engagement calculation', () {
    test('starts historical profiles honestly at one day', () {
      final update = calculateEngagementUpdate(
        current: const EngagementState(),
        now: DateTime(2026, 8, 14, 9),
      );

      expect(update.shouldWrite, isTrue);
      expect(update.state.currentStreak, 1);
      expect(update.state.longestStreak, 1);
      expect(update.state.totalActiveDays, 1);
      expect(update.state.lastActiveDay, '2026-08-14');
      expect(update.state.recentActiveDays, ['2026-08-14']);
    });

    test('is idempotent when called repeatedly on the same day', () {
      const current = EngagementState(
        currentStreak: 4,
        longestStreak: 7,
        totalActiveDays: 12,
        lastActiveDay: '2026-08-14',
      );

      final update = calculateEngagementUpdate(
        current: current,
        now: DateTime(2026, 8, 14, 23, 59),
      );

      expect(update.shouldWrite, isFalse);
      expect(identical(update.state, current), isTrue);
    });

    test('continues a streak on the next calendar day', () {
      final update = calculateEngagementUpdate(
        current: const EngagementState(
          currentStreak: 6,
          longestStreak: 6,
          totalActiveDays: 10,
          lastActiveDay: '2026-08-13',
          recentActiveDays: ['2026-08-12', '2026-08-13'],
        ),
        now: DateTime(2026, 8, 14, 0, 1),
      );

      expect(update.state.currentStreak, 7);
      expect(update.state.longestStreak, 7);
      expect(update.state.totalActiveDays, 11);
      expect(update.state.recentActiveDays.last, '2026-08-14');
    });

    test('resets the current streak after a gap but preserves the record', () {
      final update = calculateEngagementUpdate(
        current: const EngagementState(
          currentStreak: 8,
          longestStreak: 14,
          totalActiveDays: 31,
          lastActiveDay: '2026-08-10',
        ),
        now: DateTime(2026, 8, 14),
      );

      expect(update.state.currentStreak, 1);
      expect(update.state.longestStreak, 14);
      expect(update.state.totalActiveDays, 32);
    });

    test('does not overwrite progress when a future day is encountered', () {
      const current = EngagementState(
        currentStreak: 9,
        longestStreak: 9,
        totalActiveDays: 20,
        lastActiveDay: '2026-08-20',
      );

      final update = calculateEngagementUpdate(
        current: current,
        now: DateTime(2026, 8, 14),
      );

      expect(update.shouldWrite, isFalse);
      expect(update.state.currentStreak, 9);
    });

    test('recovers from malformed and negative historical values', () {
      final current = EngagementState.fromMap(const {
        'currentStreak': -4,
        'longestStreak': -1,
        'totalActiveDays': -8,
        'lastActiveDay': 'not-a-day',
        'recentActiveDays': ['bad-day'],
      });
      final update = calculateEngagementUpdate(
        current: current,
        now: DateTime(2026, 8, 14),
      );

      expect(update.state.currentStreak, 1);
      expect(update.state.longestStreak, 1);
      expect(update.state.totalActiveDays, 1);
      expect(update.state.recentActiveDays, ['2026-08-14']);
    });
  });

  test('local daily marker avoids another Firestore read on app resume',
      () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final db = MemoryFirestore();
    db.rows['user/member'] = {
      'engagement': {
        'currentStreak': 2,
        'longestStreak': 2,
        'totalActiveDays': 2,
        'lastActiveDay': '2026-09-18',
      },
    };
    final userReference = db.collection('user').doc('member');
    final now = DateTime(2026, 9, 19, 9);

    expect(
      await recordDailyEngagement(
        userReference: userReference,
        now: now,
        firestore: db,
        preferences: preferences,
      ),
      isTrue,
    );
    expect(db.reads, ['user/member']);

    expect(
      await recordDailyEngagement(
        userReference: userReference,
        now: now.add(const Duration(hours: 4)),
        firestore: db,
        preferences: preferences,
      ),
      isFalse,
    );
    expect(
      db.reads,
      ['user/member'],
      reason: 'the second resume must stop at the local daily marker',
    );
  });

  group('achievement progress', () {
    test('calculates totals and avoids division by zero', () {
      const empty = AchievementSnapshot();
      const populated = AchievementSnapshot(
        reportedWins: 3,
        reportedMisses: 1,
      );

      expect(empty.totalDeclarations, 0);
      expect(empty.winRate, 0);
      expect(populated.totalDeclarations, 4);
      expect(populated.winRate, 0.75);
    });

    test('keeps streak badges unlocked from the longest streak', () {
      const snapshot = AchievementSnapshot(
        currentStreak: 1,
        longestStreak: 7,
      );
      final sevenDayBadge =
          achievementDefinitions.firstWhere((item) => item.id == 'streak_7');

      expect(sevenDayBadge.isUnlocked(snapshot), isTrue);
      expect(nextStreakTarget(snapshot.longestStreak), 14);
    });

    test('triples each streak target after the monthly badge', () {
      for (final (record, next) in [
        (29, 30),
        (30, 90),
        (89, 90),
        (90, 270),
        (269, 270),
        (270, 810),
        (810, 2430),
        (2430, 7290),
      ]) {
        expect(nextStreakTarget(record), next);
      }
    });

    test('a past record earns each badge once and a new streak starts fresh',
        () {
      const snapshot =
          AchievementSnapshot(currentStreak: 1, longestStreak: 270);
      final streaks = achievementsFor(snapshot.bestStreak)
          .where((badge) => badge.kind == AchievementKind.streak)
          .toList();
      expect(
          streaks
              .where((badge) => badge.isUnlocked(snapshot))
              .map((badge) => badge.target),
          [3, 7, 14, 30, 90, 270]);
      expect(streaks.last.target, 810);
      expect(streaks.last.progress(snapshot), 1);
      expect(unlockedAchievementCount(snapshot), 6);
      expect(achievementCompletionValue(snapshot), 6 / 16);
    });

    test(
        'an active series also counts when a historical profile lacks its record',
        () {
      const snapshot = AchievementSnapshot(currentStreak: 90);
      expect(nextStreakTarget(snapshot.bestStreak), 270);
      expect(unlockedAchievementCount(snapshot), 5);
    });

    test('calculates membership days without inventing a future history', () {
      expect(
        membershipDays(DateTime(2026, 8, 1), DateTime(2026, 8, 14)),
        14,
      );
      expect(
        membershipDays(DateTime(2026, 8, 15), DateTime(2026, 8, 14)),
        0,
      );
      expect(membershipDays(null, DateTime(2026, 8, 14)), 0);
    });
  });
}
