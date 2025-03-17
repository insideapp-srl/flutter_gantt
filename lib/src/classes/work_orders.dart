import 'dart:ui';

import '../utils/datetime.dart';

class WorkOrders {
  late DateTime start;
  late DateTime end;
  final int workHours;
  final String title;
  final String description;
  final List<WorkOrders>? children;
  final Function(WorkOrders workOrders)? onTap;
  final Color? color;

  WorkOrders({
    required DateTime start,
    required DateTime end,
    required this.workHours,
    required this.title,
    required this.description,
    this.children,
    this.onTap,
    this.color,
  }) {
    this.start = start.dayStart;
    this.end = end.dayEnd;
  }

  int get daysDuration => (workHours / 8).ceil(); //ToDo

  DateTime get endByDays => start
      .add(Duration(days: daysDuration))
      .subtract(Duration(microseconds: 1));
}
