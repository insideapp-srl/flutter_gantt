import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';
import 'activities_grid.dart';
import 'activities_list.dart';
import 'calendar_grid.dart';

/// A customizable Gantt chart widget for Flutter.
///
/// Displays activities in a timeline view with configurable appearance and behavior.
/// The chart consists of three main components:
/// 1. ActivitiesList - Shows activity names on the left
/// 2. CalendarGrid - Shows date headers at the top
/// 3. ActivitiesGrid - Shows activity durations on the right
class Gantt extends StatefulWidget {
  /// The initial start date to display.
  final DateTime? startDate;

  /// The list of activities to display (mutually exclusive with [activitiesAsync]).
  final List<GantActivity>? activities;

  /// Async function to load activities (mutually exclusive with [activities]).
  ///
  /// This function is called when the date range changes to fetch new activities.
  final Future<List<GantActivity>> Function(
    DateTime startDate,
    DateTime endDate,
    List<GantActivity> activities,
  )?
  activitiesAsync;

  /// The list of holidays to highlight (mutually exclusive with [holidaysAsync]).
  final List<GantDateHoliday>? holidays;

  /// Async function to load holidays (mutually exclusive with [holidays]).
  final Future<List<GantDateHoliday>> Function(
    DateTime startDate,
    DateTime endDate,
    List<GantDateHoliday> holidays,
  )?
  holidaysAsync;

  /// The theme to use for the Gantt chart.
  final GanttTheme? theme;

  /// The controller for managing Gantt chart state.
  final GanttController? controller;

  /// Callback when an activity's dates changes.
  final GantActivityOnChangedEvent? onActivityChanged;

  /// Creates a [Gantt] chart widget.
  ///
  /// Throws an [AssertionError] if:
  /// - Neither [startDate] nor [controller] is provided
  /// - Both [activities] and [activitiesAsync] are provided or both are null
  /// - Both [holidays] and [holidaysAsync] are provided
  const Gantt({
    super.key,
    this.startDate,
    this.theme,
    this.activities,
    this.activitiesAsync,
    this.holidays,
    this.holidaysAsync,
    this.controller,
    this.onActivityChanged,
  }) : assert(
         (startDate != null || controller != null) &&
             ((activities == null) != (activitiesAsync == null)) &&
             (holidays == null || holidaysAsync == null),
       );

  @override
  State<Gantt> createState() => _GanttState();
}

class _GanttState extends State<Gantt> {
  late GanttTheme theme;
  late GanttController controller;
  Offset? _lastPosition;
  late LinkedScrollControllerGroup _linkedControllers;
  late ScrollController _listController;
  late ScrollController _gridColumnsController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _linkedControllers = LinkedScrollControllerGroup();
    _listController = _linkedControllers.addAndGet();
    _gridColumnsController = _linkedControllers.addAndGet();
    theme = widget.theme ?? GanttTheme();
    controller =
        widget.controller ?? GanttController(startDate: widget.startDate);
    controller.addFetchListener(_getAsync);
    if (widget.onActivityChanged != null) {
      controller.addOnActivityChangedListener(widget.onActivityChanged!);
    }
    if (widget.holidays != null) {
      controller.setHolidays(widget.holidays!, notify: false);
    }
    if (widget.activities != null) {
      controller.setActivities(widget.activities!, notify: false);
    } else {
      controller.fetch();
    }
  }

  @override
  void dispose() {
    controller.removeFetchListener(_getAsync);
    if (widget.onActivityChanged != null) {
      controller.removeOnActivityChangedListener(widget.onActivityChanged!);
    }
    if (widget.controller == null) {
      controller.dispose();
    }
    _listController.dispose();
    _gridColumnsController.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) =>
      _lastPosition = details.localPosition;

  void _handlePanUpdate(DragUpdateDetails details, double maxWidth) {
    final dayWidth = maxWidth / controller.daysViews;
    final dx = (details.localPosition.dx - _lastPosition!.dx);
    if (_lastPosition != null && dx.abs() > dayWidth) {
      if (dx.isNegative) {
        controller.next(fetchData: false);
      } else {
        controller.prev(fetchData: false);
      }
      _lastPosition = details.localPosition;
    }
  }

  void _handlePanEnd(DragEndDetails details) => _reset();

  void _handlePanCancel() => _reset();

  void _reset() {
    _lastPosition = null;
    controller.fetch();
  }

  Future<void> _getAsync() async {
    if (widget.activitiesAsync != null || widget.holidaysAsync != null) {
      var activities = <GantActivity>[];
      var holidays = <GantDateHoliday>[];
      setState(() {
        _loading = true;
      });
      if (widget.activitiesAsync != null) {
        activities = await widget.activitiesAsync!(
          controller.startDate,
          controller.endDate,
          controller.activities,
        );
        controller.setActivities(activities, notify: false);
      }
      if (widget.holidaysAsync != null) {
        holidays = await widget.holidaysAsync!(
          controller.startDate,
          controller.endDate,
          controller.holidays,
        );
        controller.setHolidays(holidays, notify: false);
      }
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      Provider<GanttTheme>.value(value: theme),
      ChangeNotifierProvider<GanttController>.value(value: controller),
    ],
    builder: (context, child) {
      final c = context.watch<GanttController>();
      return Container(
        color: theme.backgroundColor,
        child: Column(
          children: [
            SizedBox(
              height: 4,
              child: _loading ? LinearProgressIndicator() : Container(),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ActivitiesList(
                      activities: c.activities,
                      controller: _listController,
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final newDaysViews =
                            (constraints.maxWidth / theme.dayMinWidth).floor();
                        if (newDaysViews != c.daysViews) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            c.daysViews = newDaysViews;
                          });
                        }
                        return GestureDetector(
                          onPanStart: _handlePanStart,
                          onPanUpdate:
                              (details) => _handlePanUpdate(
                                details,
                                constraints.maxWidth,
                              ),
                          onPanEnd: _handlePanEnd,
                          onPanCancel: _handlePanCancel,
                          child: Stack(
                            children: [
                              CalendarGrid(holidays: c.holidays),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  controller.gridWidth = constraints.maxWidth;
                                  return ActivitiesGrid(
                                    activities: c.activities,
                                    controller: _gridColumnsController,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
