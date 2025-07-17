// controller_extension.dart
import 'package:flutter/material.dart';

import '../classes/activity.dart';
import '../utils/datetime.dart';
import 'controller.dart';

/// Internal extension methods for [GanttController] providing date calculations
/// and activity positioning logic.
extension GanttCtrlInternal on GanttController {
  /// Generates a list of dates from [startDate] for [days] duration.
  static List<DateTime> getDays(DateTime startDate, int days) =>
      List.generate(days, (i) => startDate.add(Duration(days: i)));

  /// Groups days by month and calculates days per month.
  ///
  /// Returns a map where keys are month names and values are day counts.
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

  /// Gets the English month name for 1-based month index.
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

  /// The list of dates currently visible in the Gantt chart.
  List<DateTime> get days => GanttCtrlInternal.getDays(startDate, daysViews);

  /// The months and day counts currently visible in the Gantt chart.
  Map<String, int> get months =>
      GanttCtrlInternal.getMonths(startDate, daysViews);

  /// Clamps a date to the currently visible date range.
  ///
  /// If [date] is before [startDate], returns [startDate].
  /// If [date] is after [endDate], returns [endDate].
  /// Otherwise returns the original date with time components set to zero.
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

  /// Calculates days before activity start that are visible.
  int getCellDaysBefore(GanttActivity activity) {
    final clampedStart = clampToGanttRange(activity.start);
    return clampedStart.diffInDays(startDate);
  }

  /// Calculates visible days for the activity.
  int getCellDays(GanttActivity activity) {
    final clampedStart = clampToGanttRange(activity.start);
    final clampedEnd = clampToGanttRange(
      activity.end,
    ).add(const Duration(days: 1));
    return clampedEnd.diffInDays(clampedStart);
  }

  /// Calculates days after activity end that are visible.
  int getCellsDaysAfter(GanttActivity activity) {
    final clampedEnd = clampToGanttRange(activity.end);
    return endDate.diffInDays(clampedEnd);
  }

  /// Notifies listeners when an activity's dates changes.
  void onActivityChanged(
    GanttActivity activity, {
    DateTime? start,
    DateTime? end,
  }) {
    for (var listener in onActivityChangedListeners) {
      listener(activity, start, end);
    }
  }
}

/// Controls the display state of a single activity row in the Gantt chart.
///
/// This controller manages the positioning and visibility of an individual
/// activity within the current visible date range.
class GanttActivityCtrl extends ChangeNotifier {
  /// The parent [GanttController].
  final GanttController controller;

  /// The [GanttActivity] being controlled.
  final GanttActivity activity;

  /// Creates a controller for an activity row.
  GanttActivityCtrl({required this.controller, required this.activity});

  /// The start date of the visible range.
  DateTime get startDate => controller.startDate;

  /// The number of days visible in the chart.
  int get daysViews => controller.daysViews;

  /// The list of visible dates.
  List<DateTime> get days => controller.days;

  /// The end date of the visible range.
  DateTime get endDate => controller.endDate;

  /// Whether any part of the activity is visible in the current range.
  bool get cellVisible =>
      activity.start.isDateBetween(startDate, endDate) ||
      activity.end.isDateBetween(startDate, endDate) ||
      (activity.start.isBefore(startDate) && activity.end.isAfter(endDate));

  /// Whether the activity is completely before the visible range.
  bool get showBefore => !cellVisible && activity.end.isBefore(startDate);

  /// Whether the activity is completely after the visible range.
  bool get showAfter => !cellVisible && activity.start.isAfter(endDate);

  /// The width of each day column in pixels.
  double get dayColumnWidth => controller.dayColumnWidth;

  /// Days before activity start that are visible.
  int get daysBefore => controller.getCellDaysBefore(activity);

  /// The space before the activity cell in pixels.
  double get spaceBefore => dayColumnWidth * daysBefore;

  /// Visible days for the activity.
  int get cellVisibleDays => controller.getCellDays(activity);

  /// The width of the visible portion of the activity cell.
  double get cellVisibleWidth => dayColumnWidth * cellVisibleDays;

  /// Days after activity end that are visible.
  int get daysAfter => controller.getCellsDaysAfter(activity);

  /// The space after the activity cell in pixels.
  double get spaceAfter => dayColumnWidth * daysAfter;

  /// Whether the activity starts exactly at the visible start.
  bool get cellsNotVisibleBefore =>
      daysBefore == 0 && startDate != activity.start;

  /// Whether the activity ends exactly at the visible end.
  bool get cellsNotVisibleAfter => daysAfter == 0 && endDate != activity.end;
}
