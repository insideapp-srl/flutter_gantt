import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/theme.dart';
import '../classes/work_orders.dart';

class GanttCell extends StatefulWidget {
  final WorkOrders workOrders;

  const GanttCell({super.key, required this.workOrders});

  @override
  State<GanttCell> createState() => _GanttCellState();
}

class _GanttCellState extends State<GanttCell> {
  bool mouseOver = false;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => widget.workOrders.onTap?.call(widget.workOrders),
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
            color: (widget.workOrders.color ??
                    context.watch<GanttTheme>().defaultCellColor)
                .withValues(alpha: mouseOver ? 0.7 : 1),
          ),
          child: Text(
            widget.workOrders.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ),
  );
}
