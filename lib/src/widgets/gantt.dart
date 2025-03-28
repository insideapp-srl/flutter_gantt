import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/theme.dart';
import '../classes/activity.dart';
import 'controller.dart';
import 'controller_extension.dart';
import 'row.dart';

class Gantt extends StatefulWidget {
  final DateTime? startDate;
  final int? daysViews;
  final List<GantActivity>? activities;
  final Future<List<GantActivity>> Function(
    DateTime startDate,
    DateTime endDate,
    List<GantActivity> activities,
  )?
  activitiesAsync;
  final GanttTheme? theme;
  final GanttController? controller;

  const Gantt({
    super.key,
    this.startDate,
    this.daysViews,
    this.theme,
    this.activities,
    this.activitiesAsync,
    this.controller,
  }) : assert(
         ((startDate != null && daysViews != null) || controller != null) &&
             ((activities == null) != (activitiesAsync == null)),
       );

  @override
  State<Gantt> createState() => _GanttState();
}

class _GanttState extends State<Gantt> {
  late GanttTheme theme;
  late GanttController controller;
  List<GantActivity> _activities = [];

  Offset? _lastPosition;

  @override
  void initState() {
    theme = widget.theme ?? GanttTheme();
    controller =
        widget.controller ??
        GanttController(
          startDate: widget.startDate,
          daysViews: widget.daysViews,
        );
    if (widget.activities != null) {
      _activities = widget.activities!;
    } else {
      getAsync().ignore();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) =>
      _lastPosition = details.localPosition;

  void _handlePanUpdate(DragUpdateDetails details, double maxWidth) {
    final dayWidth = maxWidth / controller.daysViews;
    final dx = (details.localPosition.dx - _lastPosition!.dx);
    if (_lastPosition != null && dx.abs() > dayWidth) {
      if (dx.isNegative) {
        controller.next(1);
      } else {
        controller.prev(1);
      }
      _lastPosition = details.localPosition;
    }
  }

  void _handlePanEnd(DragEndDetails details) => _reset();

  void _handlePanCancel() => _reset();

  void _reset() {
    _lastPosition = null;
    getAsync().ignore();
  }

  Future<void> getAsync() async {
    if (widget.activitiesAsync != null) {
      _activities = await widget.activitiesAsync!(
        controller.startDate,
        controller.endDate,
        activities,
      );
      setState(() {});
    }
  }

  List<GantActivity> get activities => _activities;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider<GanttTheme>.value(value: theme),
      ChangeNotifierProvider<GanttController>.value(value: controller),
    ],
    builder:
        (context, child) => Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(
                  top:
                      context.watch<GanttTheme>().headerHeight +
                      context.watch<GanttTheme>().rowsGroupPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    activities.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        top: context.watch<GanttTheme>().rowPadding,
                        left: 8.0,
                      ),
                      child: SizedBox(
                        height: context.watch<GanttTheme>().cellHeight,
                        child: Row(
                          children: [
                            //if (index > 0) Icon(Icons.keyboard_arrow_right),
                            //Icon(Icons.keyboard_arrow_down),
                            Text(
                              activities[index].title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder:
                    (context, constraints) => GestureDetector(
                      onPanStart: _handlePanStart,
                      onPanUpdate:
                          (details) =>
                              _handlePanUpdate(details, constraints.maxWidth),
                      onPanEnd: _handlePanEnd,
                      onPanCancel: _handlePanCancel,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(color: theme.backgroundColor),
                          ),
                          Column(
                            children: [
                              Builder(
                                builder: (context) {
                                  final months =
                                      context
                                          .watch<GanttController>()
                                          .months
                                          .entries
                                          .toList();
                                  return Row(
                                    children: List.generate(months.length, (i) {
                                      final month = months[i];
                                      return Expanded(
                                        flex: month.value,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text(
                                                  month.key,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              color:
                                                  (i < months.length - 1)
                                                      ? Colors.grey
                                                      : Colors.transparent,
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              Expanded(
                                child: Row(
                                  children: List.generate(
                                    context
                                        .watch<GanttController>()
                                        .days
                                        .length,
                                    (i) {
                                      final day =
                                          context
                                              .watch<GanttController>()
                                              .days[i];
                                      return Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 4.0,
                                                        ),
                                                    child: Text(
                                                      '${day.day}',
                                                      style:
                                                          Theme.of(
                                                            context,
                                                          ).textTheme.bodySmall,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      color:
                                                          (day.weekday == 6 ||
                                                                  day.weekday ==
                                                                      7)
                                                              ? Colors.black
                                                                  .withValues(
                                                                    alpha: .2,
                                                                  )
                                                              : Colors
                                                                  .transparent,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: double.infinity,
                                              width: 1,
                                              color:
                                                  (i <
                                                          context
                                                                  .watch<
                                                                    GanttController
                                                                  >()
                                                                  .days
                                                                  .length -
                                                              1)
                                                      ? Colors.grey
                                                      : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top:
                                  context.watch<GanttTheme>().headerHeight +
                                  context.watch<GanttTheme>().rowsGroupPadding,
                            ),
                            child: Column(
                              children: List.generate(
                                activities.length,
                                (index) => Padding(
                                  padding: EdgeInsets.only(
                                    top: context.watch<GanttTheme>().rowPadding,
                                  ),
                                  child: GanttActivityRow(
                                    activity: activities[index],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
  );
}
