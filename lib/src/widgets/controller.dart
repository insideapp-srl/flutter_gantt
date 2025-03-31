import 'package:flutter/material.dart';

import '../utils/datetime.dart';

class GanttController extends ChangeNotifier {
  DateTime _startDate;

  DateTime get startDate => _startDate;

  set startDate(DateTime value) {
    value = value.toDate;
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

  DateTime get endDate => startDate.add(Duration(days: daysViews - 1));

  void next({int days = 1, bool fetchData = true}) =>
      _addStartDate(days: -days, fetchData: fetchData);

  void prev({int days = 1, bool fetchData = true}) =>
      _addStartDate(days: days, fetchData: fetchData);

  void _addStartDate({int days = 1, bool fetchData = true}) {
    startDate = startDate.subtract(Duration(days: days));
    if (fetchData) {
      fetch();
    }
  }

  void update() => notifyListeners();

  final List<VoidCallback> _fetchListener = <VoidCallback>[];

  void addFetchListener(VoidCallback fn) => _fetchListener.add(fn);

  void removeFetchListener(VoidCallback fn) => _fetchListener.remove(fn);

  void removeAllFetchListener() {
    for (var fn in _fetchListener) {
      _fetchListener.remove(fn);
    }
  }

  void fetch() {
    for (var fn in _fetchListener) {
      fn();
    }
  }

  @override
  void dispose() {
    removeAllFetchListener();
    super.dispose();
  }

  GanttController({DateTime? startDate, int? daysViews})
    : _startDate =
          (startDate?.toDate ??
              DateTime.now().toDate.subtract(Duration(days: 30))),
      _daysViews = daysViews ?? 30;
}
