import 'package:choloto/vip/vip_history/vip_history_date_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VIP history exposes unique dates from newest to oldest', () {
    final dates = vipHistoryDates([
      DateTime(2026, 8, 10, 18),
      DateTime(2026, 8, 12, 12),
      DateTime(2026, 8, 10, 9),
      null,
    ]);

    expect(
      dates,
      [DateTime(2026, 8, 12), DateTime(2026, 8, 10)],
    );
  });

  test('VIP history date arrows stop at both boundaries', () {
    expect(
      vipHistoryDateIndex(currentIndex: 0, offset: -1, dateCount: 3),
      0,
    );
    expect(
      vipHistoryDateIndex(currentIndex: 0, offset: 1, dateCount: 3),
      1,
    );
    expect(
      vipHistoryDateIndex(currentIndex: 2, offset: 1, dateCount: 3),
      2,
    );
  });
}
