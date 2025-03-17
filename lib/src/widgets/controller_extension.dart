import 'package:flutter/cupertino.dart';

import '../classes/work_orders.dart';
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

  int _clampToGanttRange(DateTime date) => date.microsecondsSinceEpoch.clamp(
    startDate.microsecondsSinceEpoch,
    endDate.microsecondsSinceEpoch,
  );

  int getStartFlex(WorkOrders workOrders) {
    final clampedStart = DateTime.fromMicrosecondsSinceEpoch(
      _clampToGanttRange(workOrders.start),
    );
    return clampedStart.difference(startDate).inDays;
  }

  int getCellFlex(WorkOrders workOrders) {
    final clampedStart = DateTime.fromMicrosecondsSinceEpoch(
      _clampToGanttRange(workOrders.start),
    );
    final clampedEnd = DateTime.fromMicrosecondsSinceEpoch(
      _clampToGanttRange(workOrders.endByDays) + 1,
    );
    return clampedEnd.difference(clampedStart).inDays;
  }

  int getCellsFlexEnd(WorkOrders workOrders) {
    final clampedEnd = DateTime.fromMicrosecondsSinceEpoch(
      _clampToGanttRange(workOrders.endByDays),
    );
    return endDate.difference(clampedEnd).inDays;
  }
}

class GanttWorkOrdersCtrl extends ChangeNotifier {
  final GanttController controller;
  final WorkOrders workOrders;

  GanttWorkOrdersCtrl({required this.controller, required this.workOrders});

  DateTime get startDate => controller.startDate;

  int get daysViews => controller.daysViews;

  List<DateTime> get days => controller.days;

  DateTime get endDate => controller.endDate;

  bool get cellVisible =>
      workOrders.start.isDateBetween(startDate, endDate) ||
      workOrders.endByDays.isDateBetween(startDate, endDate);

  bool get showBefore =>
      !cellVisible && workOrders.endByDays.isBefore(startDate);

  bool get showAfter => !cellVisible && workOrders.start.isAfter(endDate);

  int get cellsFlexStart => controller.getStartFlex(workOrders);

  int get cellsFlex => controller.getCellFlex(workOrders);

  int get cellsFlexEnd => controller.getCellsFlexEnd(workOrders);
}
