extension DateTimeEx on DateTime {
  bool isDateBetween(DateTime start, DateTime end) =>
      !isBefore(start) && !isAfter(end);

  DateTime get dayStart => DateTime(year, month, day, 0, 0, 0, 0, 0);

  DateTime get dayEnd => DateTime(year, month, day, 23, 59, 59, 999, 999);
}
