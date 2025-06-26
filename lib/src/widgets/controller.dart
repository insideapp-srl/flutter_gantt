import 'package:flutter/material.dart';

import '../classes/activity.dart';
import '../classes/date_holiday.dart';
import '../utils/datetime.dart';


/// Controls the state and behavior of a [Gantt] widget.
class GanttController extends ChangeNotifier {
  DateTime _startDate;
  List<GantActivity> _activities = [];
  List<GantDateHoliday> _holidays = [];
  int _daysViews;

  /// The current start date of the visible range.
  DateTime get startDate => _startDate;

  /// Sets the start date and notifies listeners if changed.
  set startDate(DateTime value) {
    value = value.toDate;
    if (value != _startDate) {
      _startDate = value;
      notifyListeners();
    }
  }

  /// The list of activities in the Gantt chart.
  List<GantActivity> get activities => _activities;

  /// Sets the activities list and optionally notifies listeners.
  void setActivities(List<GantActivity> value, {bool notify = true}) {
    if (value != _activities) {
      _activities = value;
      if (notify) {
        notifyListeners();
      }
    }
  }

  /// The list of holidays in the Gantt chart.
  List<GantDateHoliday> get holidays => _holidays;

  /// Sets the holidays list and optionally notifies listeners.
  void setHolidays(List<GantDateHoliday> value, {bool notify = true}) {
    if (value != _holidays) {
      _holidays = value;
      if (notify) {
        notifyListeners();
      }
    }
  }

  /// The number of days currently visible in the chart.
  int get daysViews => _daysViews;

  /// Sets the number of visible days and notifies listeners if changed.
  set daysViews(int value) {
    if (value != _daysViews) {
      _daysViews = value;
      notifyListeners();
    }
  }

  /// The end date of the visible range (calculated).
  DateTime get endDate => startDate.add(Duration(days: daysViews - 1));

  /// Moves the view forward by [days] and optionally fetches new data.
  void next({int days = 1, bool fetchData = true}) =>
      _addStartDate(days: -days, fetchData: fetchData);

  /// Moves the view backward by [days] and optionally fetches new data.
  void prev({int days = 1, bool fetchData = true}) =>
      _addStartDate(days: days, fetchData: fetchData);

  void _addStartDate({int days = 1, bool fetchData = true}) {
    startDate = startDate.subtract(Duration(days: days));
    if (fetchData) {
      fetch();
    }
  }

  /// Forces an update of the chart and fetches new data.
  void update() {
    fetch();
    notifyListeners();
  }

  final List<VoidCallback> _fetchListener = <VoidCallback>[];

  /// Adds a listener to be called when data needs to be fetched.
  void addFetchListener(VoidCallback fn) => _fetchListener.add(fn);

  /// Removes a fetch listener.
  void removeFetchListener(VoidCallback fn) => _fetchListener.remove(fn);

  /// Removes all fetch listeners.
  void removeAllFetchListener() {
    for (var fn in _fetchListener) {
      _fetchListener.remove(fn);
    }
  }

  /// Notifies all fetch listeners to load new data.
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

  /// Creates a Gantt controller with optional start date.
  ///
  /// If no [startDate] is provided, defaults to 30 days before today.
  GanttController({DateTime? startDate})
    : _startDate =
          (startDate?.toDate ??
              DateTime.now().toDate.subtract(Duration(days: 30))),
      _daysViews = 30;
}
