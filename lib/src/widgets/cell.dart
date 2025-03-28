import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/theme.dart';
import '../classes/activity.dart';

class GanttCell extends StatefulWidget {
  final GantActivity activity;

  const GanttCell({super.key, required this.activity});

  @override
  State<GanttCell> createState() => _GanttCellState();
}

class _GanttCellState extends State<GanttCell> {
  bool mouseOver = false;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => widget.activity.onTap?.call(widget.activity),
      child: MouseRegion(
        onEnter: (event) {
          setState(() {
            mouseOver = true;
          });
        },
        onExit: (event) {
          setState(() {
            mouseOver = false;
          });
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(left: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.watch<GanttTheme>().cellRounded),
              bottomRight: Radius.circular(
                context.watch<GanttTheme>().cellRounded,
              ),
            ),
            color: (widget.activity.color ??
                    context.watch<GanttTheme>().defaultCellColor)
                .withValues(alpha: mouseOver ? 0.7 : 1),
          ),
          child: Text(
            widget.activity.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );
}
