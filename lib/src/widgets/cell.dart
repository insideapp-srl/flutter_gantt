import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/activity.dart';
import '../classes/theme.dart';
import '../widgets/controller_extension.dart';

/// A single cell representing an activity's duration in the Gantt chart.
class GanttCell extends StatefulWidget {
  /// The activity this cell represents
  final GantActivity activity;

  /// Creates a Gantt cell for the specified activity
  const GanttCell({super.key, required this.activity});

  @override
  State<GanttCell> createState() => _GanttCellState();
}

class _GanttCellState extends State<GanttCell> {
  bool mouseOver = false;

  /// Gets the cell color, falling back to theme's default if not specified
  Color get color =>
      widget.activity.color ?? context.watch<GanttTheme>().defaultCellColor;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => widget.activity.onCellTap?.call(widget.activity),
    child: MouseRegion(
      onEnter: (event) => setState(() => mouseOver = true),
      onExit: (event) => setState(() => mouseOver = false),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft:
                context.watch<GanttActivityCtrl>().cellsNotVisibleBefore
                    ? Radius.zero
                    : Radius.circular(context.watch<GanttTheme>().cellRounded),
            bottomRight:
                context.watch<GanttActivityCtrl>().cellsNotVisibleAfter
                    ? Radius.zero
                    : Radius.circular(context.watch<GanttTheme>().cellRounded),
          ),
          color: color.withValues(alpha: color.a * (mouseOver ? 0.7 : 1)),
        ),
        child:
            widget.activity.titleWidget ??
            Text(
              widget.activity.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      ),
    ),
  );
}
