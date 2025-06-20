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
}
