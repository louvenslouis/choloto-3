List<DateTime> vipHistoryDates(Iterable<DateTime?> values) {
  final dates = values
      .whereType<DateTime>()
      .map((date) => DateTime(date.year, date.month, date.day))
      .toSet()
      .toList()
    ..sort((first, second) => second.compareTo(first));
  return dates;
}

int vipHistoryDateIndex({
  required int currentIndex,
  required int offset,
  required int dateCount,
}) {
  if (dateCount <= 0) return 0;
  return (currentIndex + offset).clamp(0, dateCount - 1);
}
