import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/activity.dart';
import '../classes/theme.dart';
import 'cell.dart';
import 'controller.dart';
import 'controller_extension.dart';

class GanttActivityRow extends StatefulWidget {
  final GantActivity activity;

  const GanttActivityRow({super.key, required this.activity});

  @override
  State<GanttActivityRow> createState() => _GanttActivityRowState();
}

class _GanttActivityRowState extends State<GanttActivityRow> {
  late GanttActivityCtrl _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = GanttActivityCtrl(
      controller: context.read<GanttController>(),
      activity: widget.activity,
    );
  }

  @override
  void didUpdateWidget(GanttActivityRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activity != widget.activity) {
      _ctrl.dispose();
      _ctrl = GanttActivityCtrl(
        controller: context.read<GanttController>(),
        activity: widget.activity,
      );
      setState(() {});
    }
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

  Widget _buildContent(BuildContext context) {
    final activity = widget.activity;
    final ctrl = context.watch<GanttActivityCtrl>();

    if (!activity.showCell) return Container();

    if (ctrl.cellVisible) {
      return Row(
        children: [
          Expanded(flex: ctrl.cellsFlexStart, child: Container()),
          Expanded(
            flex: ctrl.cellsFlex,
            child: Tooltip(
              message: activity.tooltipMessage,
              richMessage:
                  activity.tooltipWidget != null
                      ? WidgetSpan(child: activity.tooltipWidget!)
                      : null,
              child: GanttCell(activity: activity),
            ),
          ),
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
