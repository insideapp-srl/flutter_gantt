import '../utils/datetime.dart';

/// Represents a holiday date in the Gantt chart.
class GantDateHoliday {
  /// The date of the holiday.
  late DateTime date;

  /// The name or description of the holiday.
  final String holiday;

  /// Creates a holiday entry with the specified date and name.
  ///
  /// The [date] is normalized to UTC with time components set to zero.
  GantDateHoliday({required DateTime date, required this.holiday}) {
    this.date = date.toDate;
  }
}
