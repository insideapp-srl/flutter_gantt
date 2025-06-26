import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/activity.dart';
import '../classes/theme.dart';
import 'cell.dart';
import 'controller.dart';
import 'controller_extension.dart';

/// A single row in the Gantt chart representing an activity
class GanttActivityRow extends StatefulWidget {
  /// The activity to display in this row
  final GantActivity activity;

  /// Creates a row for the specified activity
  const GanttActivityRow({super.key, required this.activity});

  @override
  State<GanttActivityRow> createState() => _GanttActivityRowState();
}

class _GanttActivityRowState extends State<GanttActivityRow> {
  late GanttActivityCtrl _ctrl;
  double? _startDx;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(GanttActivityRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity) {
      _ctrl.dispose();
      _createController();
      setState(() {});
    }
  }

  void _createController() {
    _ctrl = GanttActivityCtrl(
      controller: context.read<GanttController>(),
      activity: widget.activity,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _ctrl,
    builder:
        (context, child) => SizedBox(
          height: context.watch<GanttTheme>().cellHeight,
          child: _buildContent(context),
        ),
  );

  /// Builds the row content based on activity visibility
  Widget _buildContent(BuildContext context) {
    final activity = widget.activity;
    final ctrl = context.watch<GanttActivityCtrl>();

    if (!activity.showCell) return Container();

    if (ctrl.cellVisible) {
      final cellContent =
          activity.cellBuilder == null
              ? Tooltip(
                message: activity.tooltipMessage,
                richMessage:
                    activity.tooltipWidget != null
                        ? WidgetSpan(child: activity.tooltipWidget!)
                        : null,
                child: GanttCell(activity: activity),
              )
              : Row(
                children: List<Widget>.generate(
                  ctrl.cellsFlex,
                  (index) => Expanded(
                    child: activity.cellBuilder!(
                      context
                          .read<GanttController>()
                          .clampToGanttRange(activity.start)
                          .add(Duration(days: index)),
                    ),
                  ),
                ),
              );
      final theme = context.read<GanttTheme>();
      int? daysDelta;
      final dragCell = LongPressDraggable<GantActivity>(
        data: activity,
        axis: Axis.horizontal,
        feedback: Material(
          elevation: 6,
          color: Colors.transparent,
          child: ChangeNotifierProvider.value(
            value: _ctrl,
            builder:
                (context, child) => ChangeNotifierProvider.value(
                  value: theme,
                  builder:
                      (context, child) => Opacity(
                        opacity: 0.85,
                        child: SizedBox(
                          width: ctrl.cellsFlex * theme.dayMinWidth,
                          height: theme.cellHeight,
                          child: cellContent,
                        ),
                      ),
                ),
          ),
        ),

        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () {
          _startDx = null;
        },
        onDragUpdate: (details) {
          _startDx ??= details.globalPosition.dx;

          final dxTotal = details.globalPosition.dx - _startDx!;
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox == null) return;

          final boxWidth = renderBox.size.width;
          final daysVisible = _ctrl.daysViews;
          daysDelta = (dxTotal / boxWidth * daysVisible).round();
        },
        onDragEnd: (_) {
          if (daysDelta != null && daysDelta != 0) {
            //ToDo limit movement by parent limit
            _ctrl.controller.onActivityMoved(widget.activity, daysDelta!);
          }
          _startDx = null;
        },
        child: cellContent,
      );

      return Row(
        children: [
          Expanded(flex: ctrl.cellsFlexStart, child: Container()),
          Expanded(flex: ctrl.cellsFlex, child: dragCell),
          Expanded(flex: ctrl.cellsFlexEnd, child: Container()),
        ],
      );
    }

    final isBefore = ctrl.showBefore;
    final alignment = isBefore ? Alignment.centerLeft : Alignment.centerRight;
    final icon = isBefore ? Icons.navigate_before : Icons.navigate_next;
    final children =
        isBefore
            ? [Icon(icon), activity.titleWidget ?? Text(activity.title!)]
            : [activity.titleWidget ?? Text(activity.title!), Icon(icon)];

    return Align(
      alignment: alignment,
      child: Tooltip(
        message: '${activity.start.toLocal()} - ${activity.end.toLocal()}',
        child: InkWell(
          onTap:
              () => context.read<GanttController>().startDate = activity.start,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
      ),
    );
  }
}
