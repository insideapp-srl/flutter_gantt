import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/theme.dart';
import '../classes/work_orders.dart';
import 'cell.dart';
import 'controller.dart';
import 'controller_extension.dart';

class GanttWorkOrderRow extends StatelessWidget {
  final WorkOrders workOrders;

  const GanttWorkOrderRow({super.key, required this.workOrders});

  @override
  Widget build(
    BuildContext context,
  ) => ChangeNotifierProvider<GanttWorkOrdersCtrl>(
    create:
        (context) => GanttWorkOrdersCtrl(
          controller: context.read<GanttController>(),
          workOrders: workOrders,
        ),
    builder:
        (context, child) => SizedBox(
          height: context.watch<GanttTheme>().cellHeight,
          child:
              context.watch<GanttWorkOrdersCtrl>().cellVisible
                  ? Row(
                    children: [
                      Expanded(
                        flex:
                            context.watch<GanttWorkOrdersCtrl>().cellsFlexStart,
                        child: Container(),
                      ),
                      Expanded(
                        flex: context.watch<GanttWorkOrdersCtrl>().cellsFlex,
                        child: Tooltip(
                          message: workOrders.description,
                          child: GanttCell(workOrders: workOrders),
                        ),
                      ),
                      Expanded(
                        flex: context.watch<GanttWorkOrdersCtrl>().cellsFlexEnd,
                        child: Container(),
                      ),
                    ],
                  )
                  : context.watch<GanttWorkOrdersCtrl>().showBefore
                  ? Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.navigate_before, color: Colors.black),
                        Text(workOrders.title),
                      ],
                    ),
                  )
                  : Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(workOrders.title),
                        Icon(Icons.navigate_next, color: Colors.black),
                      ],
                    ),
                  ),
        ),
  );
}
