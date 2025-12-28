import 'package:flutter/material.dart';

/// A customizable theme for Gantt chart widgets.
///
/// Provides styling options for various elements of the Gantt chart,
/// including colors, dimensions, and spacing.
class GanttTheme {
  /// The background color of the Gantt chart.
  /// Defaults to [Color(0xFFF9F9F9)].
  final Color backgroundColor;

  /// The color used to highlight holiday dates.
  /// Defaults to [Color(0xFFFF6F61)].
  final Color holidayColor;

  /// The color used to highlight weekend dates.
  /// Defaults to [Color(0xFFECEFF1)].
  final Color weekendColor;

  /// The background color for today's date cell.
  /// Defaults to [Color(0xFF2979FF)].
  final Color todayBackgroundColor;

  /// The text color for today's date cell.
  /// Defaults to [Colors.white].
  final Color todayTextColor;

  /// The default color for activity cells.
  /// Defaults to [Color(0xFF81D4FA)].
  final Color defaultCellColor;

  /// The height of each activity cell in pixels.
  /// Defaults to 24.0.
  final double cellHeight;

  /// The vertical padding between rows.
  /// Defaults to 4.0.
  final double rowPadding;

  /// The vertical padding between groups of rows.
  /// Defaults to 16.0.
  final double rowsGroupPadding;

  /// The height of the header section.
  /// Defaults to 44.0.
  final double headerHeight;

  /// The minimum width of a day column in pixels.
  /// Defaults to 30.0.
  final double dayMinWidth;

  static const double _defaultCellHeight = 24.0;
  static const double _defaultRowPadding = 4.0;
  static const double _defaultRowsGroupPadding = 16.0;
  static const double _defaultHeaderHeight = 62.0;
  static const double _defaultDayMinWidth = 30.0;

  /// Creates a [GanttTheme] with customizable properties.
  const GanttTheme({
    this.backgroundColor = const Color(0xFFF9F9F9),
    this.holidayColor = const Color(0xFFFF6F61),
    this.weekendColor = const Color(0xFFECEFF1),
    this.todayBackgroundColor = const Color(0xFF2979FF),
    this.todayTextColor = Colors.white,
    this.defaultCellColor = const Color(0xFF81D4FA),
    this.cellHeight = _defaultCellHeight,
    this.rowPadding = _defaultRowPadding,
    this.rowsGroupPadding = _defaultRowsGroupPadding,
    this.headerHeight = _defaultHeaderHeight,
    this.dayMinWidth = _defaultDayMinWidth,
  });

  /// Creates a [GanttTheme] based on the current [Theme] of the [BuildContext].
  ///
  /// This factory uses the provided theme's [ColorScheme] to fill in missing
  /// colors, allowing the Gantt chart to adapt automatically to light or dark themes.
  ///
  /// You can override individual styling by providing specific color values.
  factory GanttTheme.of(
    BuildContext context, {
    Color? backgroundColor,
    Color? holidayColor,
    Color? weekendColor,
    Color? todayBackgroundColor,
    Color? todayTextColor,
    Color? defaultCellColor,
    double cellHeight = _defaultCellHeight,
    double rowPadding = _defaultRowPadding,
    double rowsGroupPadding = _defaultRowsGroupPadding,
    double headerHeight = _defaultHeaderHeight,
    double dayMinWidth = _defaultDayMinWidth,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GanttTheme(
      backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHighest,
      defaultCellColor: defaultCellColor ?? colorScheme.primary,
      weekendColor: weekendColor ?? colorScheme.surfaceContainerLow,
      holidayColor: holidayColor ?? colorScheme.surfaceContainer,
      todayBackgroundColor: todayBackgroundColor ?? colorScheme.primary,
      todayTextColor: todayTextColor ?? colorScheme.onPrimary,
      cellHeight: cellHeight,
      rowPadding: rowPadding,
      rowsGroupPadding: rowsGroupPadding,
      headerHeight: headerHeight,
      dayMinWidth: dayMinWidth,
    );
  }

  /// The border radius for activity cells, calculated as 1/3 of [cellHeight].
  double get cellRounded => cellHeight / 3;
}
