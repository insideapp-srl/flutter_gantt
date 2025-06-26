import 'package:flutter/material.dart';

import '../classes/activity.dart';
import '../utils/datetime.dart';
import 'controller.dart';

/// Internal extension methods for [GanttController] providing date calculations
extension GanttCtrlInternal on GanttController {
  /// Generates a list of dates from [startDate] for [days] duration
  static List<DateTime> getDays(DateTime startDate, int days) =>
      List.generate(days, (i) => startDate.add(Duration(days: i)));

  /// Groups days by month and calculates days per month
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

  /// Gets the English month name for 1-based month index
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

  /// The list of dates currently visible in the Gantt chart
  List<DateTime> get days => GanttCtrlInternal.getDays(startDate, daysViews);

  /// The months and day counts currently visible in the Gantt chart
  Map<String, int> get months =>
      GanttCtrlInternal.getMonths(startDate, daysViews);

  /// Clamps a date to the currently visible date range
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

  /// Calculates days before activity start that are visible
  int getCellDaysBefore(GantActivity activity) {
    final clampedStart = clampToGanttRange(activity.start);
    return clampedStart.diffInDays(startDate);
  }

  /// Calculates visible days for the activity
  int getCellDays(GantActivity activity) {
    final clampedStart = clampToGanttRange(activity.start);
    final clampedEnd = clampToGanttRange(
      activity.end,
    ).add(const Duration(days: 1));
    return clampedEnd.diffInDays(clampedStart);
  }

  /// Calculates days after activity end that are visible
  int getCellsDaysAfter(GantActivity activity) {
    final clampedEnd = clampToGanttRange(activity.end);
    return endDate.diffInDays(clampedEnd);
  }

  void onActivityStartChange(GantActivity activity, DateTime start) {
    for (var listener in onStartChangeListeners) {
      listener(activity, start);
    }
  }

  void onActivityEndChange(GantActivity activity, DateTime start) {
    for (var listener in onEndChangeListeners) {
      listener(activity, start);
    }
  }

  void onActivityMoved(GantActivity activity, int days) {
    for (var listener in onMoveListeners) {
      listener(activity, days);
    }
  }
}

/// Controls the display state of a single activity row
class GanttActivityCtrl extends ChangeNotifier {
  /// The parent Gantt controller
  final GanttController controller;

  /// The activity being controlled
  final GantActivity activity;

  /// Creates a controller for an activity row
  GanttActivityCtrl({required this.controller, required this.activity});

  /// The start date of the visible range
  DateTime get startDate => controller.startDate;

  /// The number of days visible
  int get daysViews => controller.daysViews;

  /// The list of visible dates
  List<DateTime> get days => controller.days;

  /// The end date of the visible range
  DateTime get endDate => controller.endDate;

  /// Whether any part of the activity is visible
  bool get cellVisible =>
      activity.start.isDateBetween(startDate, endDate) ||
      activity.end.isDateBetween(startDate, endDate) ||
      (activity.start.isBefore(startDate) && activity.end.isAfter(endDate));

  /// Whether the activity is completely before the visible range
  bool get showBefore => !cellVisible && activity.end.isBefore(startDate);

  /// Whether the activity is completely after the visible range
  bool get showAfter => !cellVisible && activity.start.isAfter(endDate);

  /// Days before activity start that are visible
  int get cellsFlexStart => controller.getCellDaysBefore(activity);

  /// Visible days for the activity
  int get cellsFlex => controller.getCellDays(activity);

  /// Days after activity end that are visible
  int get cellsFlexEnd => controller.getCellsDaysAfter(activity);

  /// Whether the activity starts exactly at the visible start
  bool get cellsNotVisibleBefore =>
      cellsFlexStart == 0 && startDate != activity.start;

  /// Whether the activity ends exactly at the visible end
  bool get cellsNotVisibleAfter => cellsFlexEnd == 0 && endDate != activity.end;
}
