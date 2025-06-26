import 'package:flutter/material.dart';

/// A customizable theme for Gantt chart widgets.
///
/// This class provides styling options for various elements of the Gantt chart,
/// including colors, dimensions, and spacing.
class GanttTheme extends ChangeNotifier {
  /// The background color of the Gantt chart.
  /// Defaults to [Colors.transparent].
  late Color backgroundColor;

  /// The color used to highlight holiday dates.
  /// Defaults to [Colors.orangeAccent].
  late Color holidayColor;

  /// The color used to highlight weekend dates.
  /// Defaults to [Colors.redAccent].
  late Color weekendColor;
  late Color todayBackgroundColor;
  late Color todayTextColor;

  /// The default color for activity cells.
  /// Defaults to [Colors.purple].
  late Color defaultCellColor;

  /// The height of each activity cell in pixels.
  /// Defaults to 24.0.
  late double cellHeight;

  /// The vertical padding between rows.
  /// Defaults to 4.0.
  late double rowPadding;

  /// The vertical padding between groups of rows.
  /// Defaults to 16.0.
  late double rowsGroupPadding;

  /// The height of the header section.
  /// Defaults to 44.0.
  late double headerHeight;

  /// The minimum width of a day column in pixels.
  /// Defaults to 30.0.
  late double dayMinWidth;

  static const double _defaultCellHeight = 24.0;
  static const double _defaultRowPadding = 4.0;
  static const double _defaultRowsGroupPadding = 16.0;
  static const double _defaultHeaderHeight = 44.0;
  static const double _defaultDayMinWidth = 30.0;

  /// Creates a Gantt theme with customizable properties.
  GanttTheme({
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
  /// This factory uses the provided theme's `ColorScheme` to fill in missing
  /// colors, allowing the Gantt chart to adapt automatically to light or dark themes.
  ///
  /// You can override individual styling by providing specific color values.
  factory GanttTheme.of(
      BuildContext context, {

        /// The background color of the Gantt chart (default: `colorScheme.surfaceContainerHighest`).
        Color? backgroundColor,

        /// The color used to highlight holidays (default: `colorScheme.surfaceContainer`).
        Color? holidayColor,

        /// The color used to highlight weekends (default: `colorScheme.surfaceContainerLow`).
        Color? weekendColor,

        /// The background color for the current day cell (default: `colorScheme.primary`).
        Color? todayBackgroundColor,

        /// The text color used on the current day cell (default: `colorScheme.onPrimary`).
        Color? todayTextColor,

        /// The default color used for normal Gantt cells (default: `colorScheme.primary`).
        Color? defaultCellColor,

        /// The height of each cell row in the Gantt chart.
        double cellHeight = _defaultCellHeight,

        /// Padding inside each row (top & bottom).
        double rowPadding = _defaultRowPadding,

        /// Padding between grouped row items.
        double rowsGroupPadding = _defaultRowsGroupPadding,

        /// Height of the header row showing dates.
        double headerHeight = _defaultHeaderHeight,

        /// Minimum width of each day column.
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
