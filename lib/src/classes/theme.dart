import 'package:flutter/material.dart';

class GanttTheme extends ChangeNotifier {
  final Color backgroundColor;
  final Color defaultCellColor;
  final double cellHeight;
  final double rowPadding;
  final double rowsGroupPadding;
  final double headerHeight;

  GanttTheme({
    this.backgroundColor = Colors.white,
    this.defaultCellColor = Colors.purple,
    this.cellHeight = 24.0,
    this.rowPadding = 8.0,
    this.rowsGroupPadding = 16.0,
    this.headerHeight = 30.0,
  });

  double get cellRounded => cellHeight / 3;
}
