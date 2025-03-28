import 'package:flutter/material.dart';

import '../utils/datetime.dart';

class GanttController extends ChangeNotifier {
  DateTime _startDate;

  DateTime get startDate => _startDate;

  set startDate(DateTime value) {
    if (value != _startDate) {
      _startDate = value;
      notifyListeners();
    }
  }

  int _daysViews;

  int get daysViews => _daysViews;

  set daysViews(int value) {
    if (value != _daysViews) {
      _daysViews = value;
      notifyListeners();
    }
  }

  DateTime get endDate =>
      startDate
          .subtract(Duration(microseconds: 1))
          .add(Duration(days: daysViews))
          .dayEnd;

  void next({int days = 1}) {
    startDate = startDate.add(Duration(days: days));
  }

  void prev({int days = 1}) {
    startDate = startDate.subtract(Duration(days: days));
  }

  GanttController({DateTime? startDate, int? daysViews})
    : _startDate =
          (startDate ?? DateTime.now().subtract(Duration(days: 30))).dayStart,
      _daysViews = daysViews ?? 30;
}
