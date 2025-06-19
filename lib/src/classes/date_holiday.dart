import '../utils/datetime.dart';


class GantDateHoliday {
  late DateTime date;
  final String holiday;

  GantDateHoliday({
    required DateTime date,
    required this.holiday,
  }) {
    this.date = date.toDate;
  }
}
