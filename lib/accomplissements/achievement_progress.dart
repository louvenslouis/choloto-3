import 'dart:math' as math;

import 'package:flutter/foundation.dart';

enum AchievementKind { streak, winner, participation, loyalty, profile }

@immutable
class AchievementSnapshot {
  const AchievementSnapshot({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalActiveDays = 0,
    this.recentActiveDays = const [],
    this.reportedWins = 0,
    this.reportedMisses = 0,
    this.memberDays = 0,
    this.hasCompleteProfile = false,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final List<String> recentActiveDays;
  final int reportedWins;
  final int reportedMisses;
  final int memberDays;
  final bool hasCompleteProfile;

  int get totalDeclarations => reportedWins + reportedMisses;

  double get winRate => totalDeclarations == 0
      ? 0
      : reportedWins / math.max(1, totalDeclarations);

  int progressFor(AchievementKind kind) => switch (kind) {
        AchievementKind.streak => longestStreak,
        AchievementKind.winner => reportedWins,
        AchievementKind.participation => totalDeclarations,
        AchievementKind.loyalty => memberDays,
        AchievementKind.profile => hasCompleteProfile ? 1 : 0,
      };
}

@immutable
class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.kind,
    required this.target,
    required this.assetPath,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final AchievementKind kind;
  final int target;
  final String assetPath;

  int progress(AchievementSnapshot snapshot) => snapshot.progressFor(kind);
  bool isUnlocked(AchievementSnapshot snapshot) => progress(snapshot) >= target;
  double progressValue(AchievementSnapshot snapshot) =>
      (progress(snapshot) / target).clamp(0.0, 1.0);
}

const streakBadgeAsset = 'assets/images/achievements/streak_badge_3d.png';
const winnerBadgeAsset = 'assets/images/achievements/winner_badge_3d.png';

const achievementDefinitions = <AchievementDefinition>[
  AchievementDefinition(
    id: 'streak_3',
    titleKey: 'ach_streak_3_title',
    descriptionKey: 'ach_streak_3_desc',
    kind: AchievementKind.streak,
    target: 3,
    assetPath: streakBadgeAsset,
  ),
  AchievementDefinition(
    id: 'streak_7',
    titleKey: 'ach_streak_7_title',
    descriptionKey: 'ach_streak_7_desc',
    kind: AchievementKind.streak,
    target: 7,
    assetPath: streakBadgeAsset,
  ),
  AchievementDefinition(
    id: 'streak_14',
    titleKey: 'ach_streak_14_title',
    descriptionKey: 'ach_streak_14_desc',
    kind: AchievementKind.streak,
    target: 14,
    assetPath: streakBadgeAsset,
  ),
  AchievementDefinition(
    id: 'streak_30',
    titleKey: 'ach_streak_30_title',
    descriptionKey: 'ach_streak_30_desc',
    kind: AchievementKind.streak,
    target: 30,
    assetPath: streakBadgeAsset,
  ),
  AchievementDefinition(
    id: 'winner_1',
    titleKey: 'ach_winner_1_title',
    descriptionKey: 'ach_winner_1_desc',
    kind: AchievementKind.winner,
    target: 1,
    assetPath: winnerBadgeAsset,
  ),
  AchievementDefinition(
    id: 'winner_5',
    titleKey: 'ach_winner_5_title',
    descriptionKey: 'ach_winner_5_desc',
    kind: AchievementKind.winner,
    target: 5,
    assetPath: winnerBadgeAsset,
  ),
  AchievementDefinition(
    id: 'winner_10',
    titleKey: 'ach_winner_10_title',
    descriptionKey: 'ach_winner_10_desc',
    kind: AchievementKind.winner,
    target: 10,
    assetPath: winnerBadgeAsset,
  ),
  AchievementDefinition(
    id: 'participation_1',
    titleKey: 'ach_participation_1_title',
    descriptionKey: 'ach_participation_1_desc',
    kind: AchievementKind.participation,
    target: 1,
    assetPath: winnerBadgeAsset,
  ),
  AchievementDefinition(
    id: 'participation_10',
    titleKey: 'ach_participation_10_title',
    descriptionKey: 'ach_participation_10_desc',
    kind: AchievementKind.participation,
    target: 10,
    assetPath: winnerBadgeAsset,
  ),
  AchievementDefinition(
    id: 'participation_50',
    titleKey: 'ach_participation_50_title',
    descriptionKey: 'ach_participation_50_desc',
    kind: AchievementKind.participation,
    target: 50,
    assetPath: winnerBadgeAsset,
  ),
  AchievementDefinition(
    id: 'loyalty_30',
    titleKey: 'ach_loyalty_30_title',
    descriptionKey: 'ach_loyalty_30_desc',
    kind: AchievementKind.loyalty,
    target: 30,
    assetPath: streakBadgeAsset,
  ),
  AchievementDefinition(
    id: 'loyalty_180',
    titleKey: 'ach_loyalty_180_title',
    descriptionKey: 'ach_loyalty_180_desc',
    kind: AchievementKind.loyalty,
    target: 180,
    assetPath: streakBadgeAsset,
  ),
  AchievementDefinition(
    id: 'profile_complete',
    titleKey: 'ach_profile_title',
    descriptionKey: 'ach_profile_desc',
    kind: AchievementKind.profile,
    target: 1,
    assetPath: winnerBadgeAsset,
  ),
];

int nextStreakTarget(int longestStreak) {
  for (final target in const [3, 7, 14, 30]) {
    if (longestStreak < target) {
      return target;
    }
  }
  return 30;
}

int membershipDays(DateTime? createdTime, DateTime now) {
  if (createdTime == null || createdTime.isAfter(now)) {
    return 0;
  }
  final createdDay =
      DateTime(createdTime.year, createdTime.month, createdTime.day);
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(createdDay).inDays + 1;
}
