import 'package:choloto/accomplissements/achievement_progress.dart';
import 'package:choloto/services/engagement_service.dart';
import 'package:flutter_test/flutter_test.dart';

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
