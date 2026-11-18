import 'dart:math' as math;

import '/settings/upgrade/subscription_transaction.dart';
import '/flutter_flow/internationalization.dart';

typedef VipBadgeTier = ({String name, int days});
typedef VerifiedVipTime = ({Duration elapsed, int days, bool partial});

const defaultVipBadges = <VipBadgeTier>[
  (name: 'Nouveau Membre CHOLOTO', days: 0),
  (name: 'Membre initié CHOLOTO', days: 30),
  (name: 'Membre Discipliné CHOLOTO', days: 60),
  (name: 'Membre Visionnaire CHOLOTO', days: 180),
  (name: 'Membre Loyal CHOLOTO', days: 365),
  (name: 'Membre Empereur CHOLOTO', days: 730),
  (name: 'Membre Légende CHOLOTO', days: 1095),
  (name: 'Membre Ténor CHOLOTO', days: 1460),
];

List<VipBadgeTier> readVipBadges(Map<String, dynamic>? data) {
  if (data == null) return defaultVipBadges;
  final rows = data['tiers'];
  if (rows is! List || rows.length != defaultVipBadges.length) {
    throw const FormatException('Invalid VIP tiers');
  }
  final result = <VipBadgeTier>[];
  for (final row in rows) {
    final name = row is Map ? row['name'] : null;
    final days = row is Map ? row['days'] : null;
    if (name is! String ||
        name.trim().isEmpty ||
        name.runes.length > 80 ||
        days is! int ||
        days > 36500 ||
        (result.isEmpty ? days != 0 : days <= result.last.days)) {
      throw const FormatException('Invalid VIP tier');
    }
    result.add((name: name.trim(), days: days));
  }
  return result;
}

int? vipBadgeIndex(List<VipBadgeTier> tiers, VerifiedVipTime time,
    {required bool active}) {
  if (!active && time.elapsed <= const Duration(days: 14)) return null;
  return tiers.lastIndexWhere((tier) => tier.days <= time.days);
}

String vipBadgeName(FFLocalizations l, String name) {
  final index = defaultVipBadges.indexWhere((tier) => tier.name == name);
  if (index < 0) return name;
  const en = [
    'New CHOLOTO Member',
    'Initiated CHOLOTO Member',
    'Disciplined CHOLOTO Member',
    'Visionary CHOLOTO Member',
    'Loyal CHOLOTO Member',
    'CHOLOTO Emperor',
    'CHOLOTO Legend',
    'CHOLOTO Tenor'
  ];
  const cr = [
    'Nouvo Manm CHOLOTO',
    'Manm Inisye CHOLOTO',
    'Manm Disipline CHOLOTO',
    'Manm Vizyonè CHOLOTO',
    'Manm Fidèl CHOLOTO',
    'Manm Anperè CHOLOTO',
    'Manm Lejand CHOLOTO',
    'Manm Tenò CHOLOTO'
  ];
  return l.getVariableText(frText: name, enText: en[index], crText: cr[index]);
}

bool _signupExpiry(DateTime? date, DateTime? created, DateTime? onboarded) =>
    date == null ||
    (created != null &&
        date.millisecondsSinceEpoch <= created.millisecondsSinceEpoch) ||
    date.millisecondsSinceEpoch == onboarded?.millisecondsSinceEpoch;

bool hasActiveVipForBadge({
  required DateTime? expiry,
  required DateTime? created,
  required DateTime? onboarded,
  required DateTime now,
}) =>
    expiry != null &&
    !expiry.isBefore(now) &&
    !_signupExpiry(expiry, created, onboarded);

/// Accumulates only linked receipt intervals, following the dashboard's VIP duration.
VerifiedVipTime verifiedVipTime({
  required List<SubscriptionTransaction> history,
  required DateTime? expiry,
  required int memberTime,
  required DateTime? created,
  required DateTime? onboarded,
  required DateTime now,
}) {
  if (history.isEmpty) {
    return (
      elapsed: Duration.zero,
      days: 0,
      partial: memberTime != 0 || !_signupExpiry(expiry, created, onboarded)
    );
  }
  // Sort oldest first. Use the Firestore document ID to break timestamp ties.
  final events = history.toList()
    ..sort((a, b) {
      final cmp = (a.createdAt?.millisecondsSinceEpoch ?? 0)
          .compareTo(b.createdAt?.millisecondsSinceEpoch ?? 0);
      return cmp == 0 ? a.id.compareTo(b.id) : cmp;
    });
  var partial =
      !_signupExpiry(events.first.previousEndSub, created, onboarded) ||
          events.first.memberTimeBefore != 0;
  final nowMs = now.millisecondsSinceEpoch;
  var elapsed = 0;
  for (var i = 0; i < events.length; i++) {
    final event = events[i];
    final next = i + 1 < events.length ? events[i + 1] : null;
    final start = event.createdAt?.millisecondsSinceEpoch;
    final nextStart =
        next == null ? nowMs : next.createdAt?.millisecondsSinceEpoch;
    if (start == null || nextStart == null) {
      return (elapsed: Duration.zero, days: 0, partial: true);
    }
    if (start > nowMs) break;
    final end = event.newEndSub?.millisecondsSinceEpoch;
    final expectedEnd =
        (next == null ? expiry : next.previousEndSub)?.millisecondsSinceEpoch;
    final expectedCount = next == null ? memberTime : next.memberTimeBefore;
    if (end != expectedEnd ||
        event.memberTimeAfter == null ||
        event.memberTimeAfter != expectedCount) {
      partial = true;
      continue;
    }
    if (event.transactionType == 'cancellation') continue;
    if (end == null) {
      partial = true;
      continue;
    }
    elapsed += math.max(0, math.min(nowMs, math.min(end, nextStart)) - start);
  }
  // Keep display rounding separate from the strict retention threshold.
  final displayMs = !partial && (expiry == null || !expiry.isAfter(now))
      ? (elapsed / Duration.millisecondsPerMinute).round() *
          Duration.millisecondsPerMinute
      : elapsed;
  return (
    elapsed: Duration(milliseconds: elapsed),
    days: displayMs ~/ Duration.millisecondsPerDay,
    partial: partial
  );
}
