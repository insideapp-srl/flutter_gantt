import 'package:flutter/material.dart';

import '../classes/activity.dart';
import '../classes/date_holiday.dart';
import '../utils/datetime.dart';

/// Callback type for activity dates changes.
typedef GanttActivityOnChangedEvent =
    void Function(GanttActivity activity, DateTime? start, DateTime? end);

/// Controls the state and behavior of a [Gantt] widget.
///
/// This controller manages the timeline view, activities data, and handles
/// user interactions like date range changes and activity modifications.
class GanttController extends ChangeNotifier {
  DateTime _startDate;
  List<GanttActivity> _activities = [];
  List<GantDateHoliday> _holidays = [];
  int _daysViews;
  final List<GanttActivityOnChangedEvent> _onActivityChangedListeners = [];
  double gridWidth = 0;
  List<DateTime> _highlightedDates = [];
  bool _enableDraggable = true;
  bool _allowParentIndependentDateMovement = false;

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
  List<GanttActivity> get activities => _activities;

  /// Sets the activities list and optionally notifies listeners.
  void setActivities(List<GanttActivity> value, {bool notify = true}) {
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

  /// The list of highlighted dates in the Gantt chart.
  List<DateTime> get highlightedDates => _highlightedDates;

  /// Sets the highlighted dates list and optionally notifies listeners.
  void setHighlightedDates(List<DateTime> value, {bool notify = true}) {
    if (value != _highlightedDates) {
      _highlightedDates = value;
      if (notify) {
        notifyListeners();
      }
    }
  }

  /// Return if a date has to be highlighted.
  bool dateToHighlight(DateTime date) =>
      _highlightedDates.map((e) => e.toDate).contains(date.toDate) == true ||
      _highlightedDates.map((e) => e.toDate).contains(date.addDays(1).toDate) ==
          true;

  /// The enable draggable value.
  bool get enableDraggable => _enableDraggable;

  /// Sets the enable draggable value.
  set enableDraggable(bool value) {
    if (value != _enableDraggable) {
      _enableDraggable = value;
      notifyListeners();
    }
  }

  /// The allow parent independent date movement value.
  bool get allowParentIndependentDateMovement =>
      _allowParentIndependentDateMovement;

  /// Sets the allow parent independent date movement value.
  set allowParentIndependentDateMovement(bool value) {
    if (value != _allowParentIndependentDateMovement) {
      _allowParentIndependentDateMovement = value;
      notifyListeners();
    }
  }

  /// The number of days currently visible in the chart.
  int get daysViews => _daysViews;

  /// The calculated width of each day column based on current grid width.
  double get dayColumnWidth => gridWidth / daysViews;

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
  ///
  /// [days] - Number of days to move forward (default: 1)
  /// [fetchData] - Whether to trigger data fetch (default: true)
  void next({int days = 1, bool fetchData = true}) =>
      _addStartDate(days: -days, fetchData: fetchData);

  /// Moves the view backward by [days] and optionally fetches new data.
  ///
  /// [days] - Number of days to move backward (default: 1)
  /// [fetchData] - Whether to trigger data fetch (default: true)
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

  /// Creates a [GanttController] with optional start date.
  ///
  /// If no [startDate] is provided, defaults to 30 days before today.
  GanttController({DateTime? startDate})
    : _startDate =
          (startDate?.toDate ??
              DateTime.now().toDate.subtract(Duration(days: 30))),
      _daysViews = 30;

  /// Adds a listener for activity dates changes.
  void addOnActivityChangedListener(GanttActivityOnChangedEvent listener) {
    _onActivityChangedListeners.add(listener);
  }

  /// Removes a listener for activity dates changes.
  void removeOnActivityChangedListener(GanttActivityOnChangedEvent listener) {
    _onActivityChangedListeners.remove(listener);
  }

  /// Gets the list of dates change listeners.
  List<GanttActivityOnChangedEvent> get onActivityChangedListeners =>
      _onActivityChangedListeners;
}
