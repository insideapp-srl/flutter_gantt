import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/activity.dart';
import '../classes/theme.dart';
import '../utils/datetime.dart';
import 'cell.dart';
import 'controller.dart';
import 'controller_extension.dart';

/// A single row in the Gantt chart representing an activity.
///
/// This widget handles the display and interaction for a single activity,
/// including drag-to-move and resize functionality.
class GanttActivityRow extends StatefulWidget {
  /// The [GantActivity] to display in this row.
  final GantActivity activity;

  /// Creates a row for the specified activity.
  const GanttActivityRow({super.key, required this.activity});

  @override
  State<GanttActivityRow> createState() => _GanttActivityRowState();
}

class _GanttActivityRowState extends State<GanttActivityRow> {
  late GanttActivityCtrl _ctrl;
  double? _movementX;
  double? _movementStartX;
  double? _movementStartOffset;
  double? _movementEndX;
  double? _movementEndOffset;
  int? daysDelta;

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

  /// Builds the row content based on activity visibility.
  Widget _buildContent(BuildContext context) {
    final activity = widget.activity;
    final ctrl = context.watch<GanttActivityCtrl>();

    if (!activity.showCell) return Container();

    final theme = context.read<GanttTheme>();
    if (ctrl.cellVisible) {
      final Widget draggableEdge = MouseRegion(
        cursor: SystemMouseCursors.resizeRight,
        child: Container(
          color: Colors.white.withValues(alpha: .3),
          width: 4,
          height: theme.cellHeight / 1.5,
        ),
      );
      final cellContent = Stack(
        fit: StackFit.expand,
        children: [
          activity.builder != null
              ? activity.builder!(activity)
              : activity.cellBuilder != null
              ? Row(
                children: List<Widget>.generate(
                  ctrl.cellVisibleDays,
                  (index) => Expanded(
                    child: activity.cellBuilder!(
                      context
                          .read<GanttController>()
                          .clampToGanttRange(activity.start)
                          .add(Duration(days: index)),
                    ),
                  ),
                ),
              )
              : Tooltip(
                message: activity.tooltipMessage ?? '',
                child: GanttCell(activity: activity),
              ),
          Positioned(
            left: 0,
            bottom: 0,
            child: LongPressDraggable<GantActivity>(
              feedback: draggableEdge,
              data: activity,
              axis: Axis.horizontal,
              child: draggableEdge,
              onDragStarted: () {
                _movementStartX = null;
                _movementStartOffset = null;
              },
              onDragUpdate: (details) {
                setState(() {
                  _movementStartX ??= details.globalPosition.dx;
                  final dxTotal = details.globalPosition.dx - _movementStartX!;
                  daysDelta = (dxTotal / _ctrl.dayColumnWidth).round();
                  _movementStartOffset = _ctrl.dayColumnWidth * daysDelta!;
                });
              },
              onDragEnd: (_) {
                if (daysDelta != null && daysDelta != 0) {
                  _ctrl.controller.onActivityChanged(
                    widget.activity,
                    start: widget.activity.start.addDays(daysDelta!),
                  );
                }
                _movementStartX = null;
                _movementStartOffset = null;
              },
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: LongPressDraggable<GantActivity>(
              feedback: draggableEdge,
              data: activity,
              axis: Axis.horizontal,
              child: draggableEdge,
              onDragStarted: () {
                _movementEndX = null;
                _movementEndOffset = null;
              },
              onDragUpdate: (details) {
                setState(() {
                  _movementEndX ??= details.globalPosition.dx;
                  final dxTotal = details.globalPosition.dx - _movementEndX!;
                  daysDelta = (dxTotal / _ctrl.dayColumnWidth).round();
                  _movementEndOffset = _ctrl.dayColumnWidth * daysDelta!;
                });
              },
              onDragEnd: (_) {
                if (daysDelta != null && daysDelta != 0) {
                  _ctrl.controller.onActivityChanged(
                    widget.activity,
                    end: widget.activity.end.addDays(daysDelta!),
                  );
                }
                _movementEndX = null;
                _movementEndOffset = null;
              },
            ),
          ),
        ],
      );

      final dragCell = LongPressDraggable<GantActivity>(
        data: activity,
        axis: Axis.horizontal,
        feedback: Material(
          elevation: 6,
          color: Colors.transparent,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _ctrl),
              Provider.value(value: theme),
            ],
            builder:
                (context, child) => Opacity(
                  opacity: 0.85,
                  child: SizedBox(
                    width: ctrl.cellVisibleWidth,
                    height: theme.cellHeight,
                    child: cellContent,
                  ),
                ),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () {
          _movementX = null;
        },
        onDragUpdate: (details) {
          _movementX ??= details.globalPosition.dx;
          final dxTotal = details.globalPosition.dx - _movementX!;
          daysDelta = (dxTotal / _ctrl.dayColumnWidth).round();
        },
        onDragEnd: (_) {
          if (daysDelta != null && daysDelta != 0) {
            _ctrl.controller.onActivityChanged(
              widget.activity,
              start: widget.activity.start.addDays(daysDelta!),
              end: widget.activity.end.addDays(daysDelta!),
            );
          }
          _movementX = null;
        },
        child: cellContent,
      );

      return Row(
        children: [
          SizedBox(
            width: ctrl.spaceBefore + (_movementStartOffset ?? 0),
            child: Container(),
          ),
          SizedBox(
            width:
                ctrl.cellVisibleWidth -
                (_movementStartOffset ?? 0) +
                (_movementEndOffset ?? 0),
            child: dragCell,
          ),
          SizedBox(
            width: ctrl.spaceAfter - (_movementEndOffset ?? 0),
            child: Container(),
          ),
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
