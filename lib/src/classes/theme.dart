import 'package:flutter/material.dart';

/// A customizable theme for Gantt chart widgets.
///
/// This class provides styling options for various elements of the Gantt chart,
/// including colors, dimensions, and spacing.
class GanttTheme extends ChangeNotifier {
  /// The background color of the Gantt chart.
  /// Defaults to [Colors.transparent].
  final Color backgroundColor;

  /// The color used to highlight holiday dates.
  /// Defaults to [Colors.orangeAccent].
  final Color holidayColor;

  /// The color used to highlight weekend dates.
  /// Defaults to [Colors.redAccent].
  final Color weekendColor;

  /// The default color for activity cells.
  /// Defaults to [Colors.purple].
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

  /// Creates a Gantt theme with customizable properties.
  GanttTheme({
    this.backgroundColor = Colors.transparent,
    this.holidayColor = Colors.orangeAccent,
    this.weekendColor = Colors.redAccent,
    this.defaultCellColor = Colors.purple,
    this.cellHeight = 24.0,
    this.rowPadding = 4.0,
    this.rowsGroupPadding = 16.0,
    this.headerHeight = 44.0,
    this.dayMinWidth = 30.0,
  });

  /// The border radius for activity cells, calculated as 1/3 of [cellHeight].
  double get cellRounded => cellHeight / 3;
}
