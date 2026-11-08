import 'package:choloto/ads/draw_ad_eligibility.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 11, 8);
  final expired = Timestamp.fromDate(now.subtract(const Duration(days: 1)));
  bool eligible(Map<String, dynamic>? profile,
          {bool cached = false, bool pending = false}) =>
      isConfirmedFreeProfile(
          uid: 'owner',
          data: profile,
          fromCache: cached,
          pendingWrites: pending,
          now: now);

  test('only a confirmed free profile can request the banner', () {
    expect(eligible(null), isFalse);
    expect(eligible({}), isFalse);
    expect(eligible({'end_sub': 'unknown'}), isFalse);
    expect(eligible({'uid': 'foreign', 'end_sub': expired}), isFalse);
    final profile = {'uid': 'owner', 'end_sub': expired};
    expect(eligible(profile, cached: true), isFalse);
    expect(eligible(profile, pending: true), isFalse);
    expect(eligible(profile), isTrue);
    expect(eligible({'end_sub': expired}), isTrue);
    expect(eligible({'end_sub': Timestamp.fromDate(now)}), isFalse);
    expect(
        eligible(
            {'end_sub': Timestamp.fromDate(now.add(const Duration(days: 30)))}),
        isFalse);
  });
}
