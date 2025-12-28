// controller_extension.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../flutter_gantt.dart';
import '../utils/datetime.dart';

/// Internal extension methods for [GanttController] providing date calculations
/// and activity positioning logic.
extension GanttCtrlInternal on GanttController {
  /// Generates a list of dates from [startDate] for [days] duration.
  static List<DateTime> getDays(DateTime startDate, int days) =>
      List.generate(days, (i) => startDate.add(Duration(days: i)));

  /// Groups days by month and calculates days per month.
  ///
  /// Returns a map where keys are month names and values are day counts.
  static Map<String, int> getNamedMonths(
    BuildContext context,
    DateTime startDate,
    int days,
    MonthToText? monthToText,
  ) {
    final locale = Localizations.localeOf(context).toLanguageTag();
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

      final monthName =
          monthToText?.call(context, currentDate) ??
          _monthName(currentDate.month, locale);

      result[monthName] = (result[monthName] ?? 0) + countedDays;

      remainingDays -= countedDays;
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }

    return result;
  }

  /// Returns the localized month name for a 1-based month index.
  ///
  /// Uses the ICU/CLDR data provided by the `intl` package.
  /// Example:
  /// ```dart
  /// monthName(3, locale: 'it'); // → "marzo"
  /// monthName(3, locale: 'en'); // → "March"
  /// ```
  ///
  /// [locale] must be a valid ICU locale like "en", "it", "es", "fr", "de", etc.
  static String _monthName(int month, String locale) {
    final date = DateTime(2000, month, 1);
    final name = DateFormat.MMMM(locale).format(date);
    return name[0].toUpperCase() + name.substring(1);
  }

  /// The number of days currently visible in the chart.
  int get internalDaysViews {
    if (daysViews != null) {
      return daysViews!;
    }
    return (gridWidth / theme.dayMinWidth).floor();
  }

  /// The calculated width of each day column based on current grid width.
  double get dayColumnWidth => gridWidth / internalDaysViews;

  /// The end date of the visible range (calculated).
  DateTime get endDate => startDate.add(Duration(days: internalDaysViews - 1));

  /// The list of dates currently visible in the Gantt chart.
  List<DateTime> get days =>
      GanttCtrlInternal.getDays(startDate, internalDaysViews);

  /// The months and day counts currently visible in the Gantt chart.
  Map<String, int> getMonths(BuildContext context, MonthToText? monthToText) =>
      GanttCtrlInternal.getNamedMonths(
        context,
        startDate,
        internalDaysViews,
        monthToText,
      );

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

  /// Returns a map of ISO week numbers to the number of days
  /// contained in each week within the current visible range.
  ///
  /// Example:
  /// `{1: 7, 2: 7, 3: 5}`

  Map<int, int> get weeks {
    final map = <int, int>{};
    for (final d in days) {
      final w = d.isoWeekNumber;
      map[w] = (map[w] ?? 0) + 1;
    }
    return map;
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
