/// Extension methods for [DateTime] used in the Gantt chart.
extension DateTimeEx on DateTime {
  /// Checks if this date is between [start] and [end] (inclusive).
  bool isDateBetween(DateTime start, DateTime end) =>
      !isBefore(start) && !isAfter(end);

  /// Checks if this date is before or the same as [other].
  bool isBeforeOrSame(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);

  /// Checks if this date is after or the same as [other].
  bool isAfterOrSame(DateTime other) =>
      isAfter(other) || isAtSameMomentAs(other);

  /// Returns a new DateTime at the start of this day (00:00:00).
  DateTime get dayStart => DateTime(year, month, day, 0, 0, 0, 0, 0);

  /// Returns a new DateTime at the end of this day (23:59:59.999).
  DateTime get dayEnd => DateTime(year, month, day, 23, 59, 59, 999, 999);

  /// Returns a UTC date with time components set to zero.
  DateTime get toDate => DateTime.utc(year, month, day, 0, 0, 0, 0, 0);

  /// Calculates the difference in days between this date and [other].
  int diffInDays(DateTime other) => difference(other).inDays;

  /// Whether this date is today.
  bool get isToday => dayStart.compareTo(DateTime.now().dayStart) == 0;

  /// Whether this date falls on a weekend (Saturday or Sunday).
  bool get isWeekend => weekday == 6 || weekday == 7;

  /// Adds a number of days to this [DateTime] and returns the resulting date.
  ///
  /// Equivalent to:
  /// ```dart
  /// date.add(Duration(days: days))
  /// ```
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtracts a number of days from this [DateTime] and returns the resulting date.
  ///
  /// Equivalent to:
  /// ```dart
  /// date.subtract(Duration(days: days))
  /// ```
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Returns the earliest of the two given dates.
  ///
  /// If [d1] and [d2] are equal, [d1] is returned.
  static DateTime firstDate(DateTime d1, DateTime d2) =>
      d1.isBeforeOrSame(d2) ? d1 : d2;

  /// Returns the latest of the two given dates.
  ///
  /// If [d1] and [d2] are equal, [d1] is returned.
  static DateTime lastDate(DateTime d1, DateTime d2) =>
      d1.isAfterOrSame(d2) ? d1 : d2;

  /// Returns the earliest date in the provided [dates] list.
  ///
  /// Throws a [StateError] if the list is empty.
  static DateTime firstDateFromList(List<DateTime> dates) =>
      dates.reduce((value, element) => DateTimeEx.firstDate(value, element));

  /// Returns the latest date in the provided [dates] list.
  ///
  /// Throws a [StateError] if the list is empty.
  static DateTime lastDateFromList(List<DateTime> dates) =>
      dates.reduce((value, element) => DateTimeEx.lastDate(value, element));

  /// Returns the ISO-8601 week number for this date.
  ///
  /// ISO weeks start on Monday and week 1 is the week containing the first Thursday.
  int get isoWeekNumber {
    final thursday = add(Duration(days: (4 - weekday)));
    final beginningOfYear = DateTime(thursday.year, 1, 1);
    final diff = thursday.difference(beginningOfYear).inDays;
    return (diff / 7).floor() + 1;
  }
}
