extension DateTimeEx on DateTime {
  bool isDateBetween(DateTime start, DateTime end) =>
      !isBefore(start) && !isAfter(end);

  bool isBeforeOrSame(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);

  bool isAfterOrSame(DateTime other) =>
      isAfter(other) || isAtSameMomentAs(other);

  DateTime get dayStart => DateTime(year, month, day, 0, 0, 0, 0, 0);

  DateTime get dayEnd => DateTime(year, month, day, 23, 59, 59, 999, 999);

  DateTime get toDate => DateTime.utc(year, month, day, 0, 0, 0, 0, 0);

  int diffInDays(DateTime other) => difference(other).inDays;

  bool get isToday => dayStart.compareTo(DateTime.now().dayStart) == 0;
}
