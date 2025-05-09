import 'package:flutter/material.dart';

import '../classes/activity.dart';
import '../utils/datetime.dart';
import 'controller.dart';

extension GanttCtrlInternal on GanttController {
  static List<DateTime> getDays(DateTime startDate, int days) =>
      List.generate(days, (i) => startDate.add(Duration(days: i)));

  static Map<String, int> getMonths(DateTime startDate, int days) {
    final result = <String, int>{};
    var currentDate = startDate;
    var remainingDays = days;

    while (remainingDays > 0) {
      final daysInMonth =
          DateTime(currentDate.year, currentDate.month + 1, 0).day;
      final startDay = currentDate.day;
      final daysLeftInMonth = daysInMonth - startDay + 1;
      final countedDays =
          remainingDays < daysLeftInMonth ? remainingDays : daysLeftInMonth;

      final monthName = _monthName(currentDate.month);
      result[monthName] = (result[monthName] ?? 0) + countedDays;

      remainingDays -= countedDays;
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    return result;
  }

  static String _monthName(int month) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month];
  }

  List<DateTime> get days => GanttCtrlInternal.getDays(startDate, daysViews);

  Map<String, int> get months =>
      GanttCtrlInternal.getMonths(startDate, daysViews);

  DateTime clampToGanttRange(DateTime date) {
    final clampedMicroseconds = date.microsecondsSinceEpoch.clamp(
      startDate.microsecondsSinceEpoch,
      endDate.microsecondsSinceEpoch,
    );
    return DateTime.fromMicrosecondsSinceEpoch(
      clampedMicroseconds,
      isUtc: true,
    ).copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  }

  int getCellDaysBefore(GantActivity activity) {
    final clampedStart = clampToGanttRange(activity.start);
    return clampedStart.diffInDays(startDate);
  }

  int getCellDays(GantActivity activity) {
    final clampedStart = clampToGanttRange(activity.start);
    final clampedEnd = clampToGanttRange(
      activity.end,
    ).add(const Duration(days: 1));

    return clampedEnd.diffInDays(clampedStart);
  }

  int getCellsDaysAfter(GantActivity activity) {
    final clampedEnd = clampToGanttRange(activity.end);
    return endDate.diffInDays(clampedEnd);
  }
}

class GanttActivityCtrl extends ChangeNotifier {
  final GanttController controller;
  final GantActivity activity;

  GanttActivityCtrl({required this.controller, required this.activity});

  DateTime get startDate => controller.startDate;

  int get daysViews => controller.daysViews;

  List<DateTime> get days => controller.days;

  DateTime get endDate => controller.endDate;

  bool get cellVisible =>
      activity.start.isDateBetween(startDate, endDate) ||
      activity.end.isDateBetween(startDate, endDate) ||
      (activity.start.isBefore(startDate) && activity.end.isAfter(endDate));

  bool get showBefore => !cellVisible && activity.end.isBefore(startDate);

  bool get showAfter => !cellVisible && activity.start.isAfter(endDate);

  int get cellsFlexStart => controller.getCellDaysBefore(activity);

  int get cellsFlex => controller.getCellDays(activity);

  int get cellsFlexEnd => controller.getCellsDaysAfter(activity);

  bool get cellsNotVisibleBefore =>
      cellsFlexStart == 0 && startDate != activity.start;

  bool get cellsNotVisibleAfter => cellsFlexEnd == 0 && endDate != activity.end;
}
