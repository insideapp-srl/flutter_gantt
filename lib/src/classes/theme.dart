import 'package:flutter/material.dart';

class GanttTheme extends ChangeNotifier {
  final Color backgroundColor;
  final Color holidayColor;
  final Color weekendColor;
  final Color defaultCellColor;
  final double cellHeight;
  final double rowPadding;
  final double rowsGroupPadding;
  final double headerHeight;
  final double dayMinWidth;

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

  double get cellRounded => cellHeight / 3;
}
