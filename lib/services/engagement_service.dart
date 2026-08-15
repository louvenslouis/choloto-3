import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class EngagementState {
  const EngagementState({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalActiveDays = 0,
    this.lastActiveDay = '',
    this.recentActiveDays = const [],
    this.timeZoneOffsetMinutes = 0,
  });

  factory EngagementState.fromMap(Map<String, dynamic>? map) {
    int safeInt(String key) {
      final value = map?[key];
      return value is num ? math.max(0, value.toInt()) : 0;
    }

    final recentDays = map?['recentActiveDays'];
    return EngagementState(
      currentStreak: safeInt('currentStreak'),
      longestStreak: safeInt('longestStreak'),
      totalActiveDays: safeInt('totalActiveDays'),
      lastActiveDay: map?['lastActiveDay'] is String
          ? map!['lastActiveDay'] as String
          : '',
      recentActiveDays: recentDays is Iterable
          ? recentDays.whereType<String>().toList(growable: false)
          : const [],
      timeZoneOffsetMinutes: map?['timeZoneOffsetMinutes'] is num
          ? (map!['timeZoneOffsetMinutes'] as num).toInt()
          : 0,
    );
  }

  final int currentStreak;
  final int longestStreak;
  final int totalActiveDays;
  final String lastActiveDay;
  final List<String> recentActiveDays;
  final int timeZoneOffsetMinutes;

  Map<String, dynamic> toMap() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalActiveDays': totalActiveDays,
        'lastActiveDay': lastActiveDay,
        'recentActiveDays': recentActiveDays,
        'timeZoneOffsetMinutes': timeZoneOffsetMinutes,
      };
}

@immutable
class EngagementUpdate {
  const EngagementUpdate({required this.state, required this.shouldWrite});

  final EngagementState state;
  final bool shouldWrite;
}

String engagementDayKey(DateTime value) {
  final local = value.toLocal();
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)}';
}

DateTime? _parseDayKey(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) {
    return null;
  }
  final parsed = DateTime.utc(year, month, day);
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    return null;
  }
  return parsed;
}

EngagementUpdate calculateEngagementUpdate({
  required EngagementState current,
  required DateTime now,
}) {
  final todayKey = engagementDayKey(now);
  final today = _parseDayKey(todayKey)!;
  final previousDay = _parseDayKey(current.lastActiveDay);

  if (previousDay != null) {
    final difference = today.difference(previousDay).inDays;
    if (difference <= 0) {
      return EngagementUpdate(state: current, shouldWrite: false);
    }
  }

  final continued = previousDay != null &&
      today.difference(previousDay).inDays == 1 &&
      current.currentStreak > 0;
  final nextStreak = continued ? current.currentStreak + 1 : 1;
  final recentDays = <String>{
    ...current.recentActiveDays.where((day) {
      final parsed = _parseDayKey(day);
      return parsed != null && !parsed.isAfter(today);
    }),
    todayKey,
  }.toList()
    ..sort();
  final boundedRecentDays = recentDays.length <= 30
      ? recentDays
      : recentDays.sublist(recentDays.length - 30);

  return EngagementUpdate(
    shouldWrite: true,
    state: EngagementState(
      currentStreak: nextStreak,
      longestStreak: math.max(current.longestStreak, nextStreak),
      totalActiveDays: current.totalActiveDays + 1,
      lastActiveDay: todayKey,
      recentActiveDays: boundedRecentDays,
      timeZoneOffsetMinutes: now.timeZoneOffset.inMinutes,
    ),
  );
}

/// Records one symbolic active day without ever blocking authentication or
/// navigation. The transaction makes repeated calls on the same day idempotent.
Future<bool> recordDailyEngagement({
  required DocumentReference? userReference,
  DateTime? now,
}) async {
  if (userReference == null) {
    return false;
  }

  try {
    return await FirebaseFirestore.instance
        .runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(userReference);
      if (!snapshot.exists) {
        // First-login profile creation owns this case. Tracking never creates a
        // competing profile and therefore cannot alter the historical flow.
        return false;
      }
      final data = snapshot.data() as Map<String, dynamic>?;
      final engagementData = data?['engagement'];
      final current = EngagementState.fromMap(
        engagementData is Map
            ? Map<String, dynamic>.from(engagementData)
            : null,
      );
      final update = calculateEngagementUpdate(
        current: current,
        now: now ?? DateTime.now(),
      );
      if (!update.shouldWrite) {
        return false;
      }

      transaction.update(userReference, {
        'engagement': {
          ...update.state.toMap(),
          'lastActiveAt': FieldValue.serverTimestamp(),
        },
      });
      return true;
    });
  } catch (error, stackTrace) {
    debugPrint('Daily engagement tracking skipped: $error');
    debugPrintStack(stackTrace: stackTrace);
    return false;
  }
}
