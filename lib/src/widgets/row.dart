import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/theme.dart';
import '../classes/activity.dart';
import 'cell.dart';
import 'controller.dart';
import 'controller_extension.dart';

class GanttActivityRow extends StatelessWidget {
  final GantActivity activity;

  const GanttActivityRow({super.key, required this.activity});

  @override
  Widget build(
    BuildContext context,
  ) => ChangeNotifierProvider<GanttActivityCtrl>(
    create:
        (context) => GanttActivityCtrl(
          controller: context.read<GanttController>(),
          activity: activity,
        ),
    builder:
        (context, child) => SizedBox(
          height: context.watch<GanttTheme>().cellHeight,
          child:
              context.watch<GanttActivityCtrl>().cellVisible
                  ? Row(
                    children: [
                      Expanded(
                        flex:
                            context.watch<GanttActivityCtrl>().cellsFlexStart,
                        child: Container(),
                      ),
                      Expanded(
                        flex: context.watch<GanttActivityCtrl>().cellsFlex,
                        child: Tooltip(
                          message: activity.description,
                          child: GanttCell(activity: activity),
                        ),
                      ),
                      Expanded(
                        flex: context.watch<GanttActivityCtrl>().cellsFlexEnd,
                        child: Container(),
                      ),
                    ],
                  )
                  : context.watch<GanttActivityCtrl>().showBefore
                  ? Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.navigate_before, color: Colors.black),
                        Text(activity.title),
                      ],
                    ),
                  )
                  : Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(activity.title),
                        Icon(Icons.navigate_next, color: Colors.black),
                      ],
                    ),
                  ),
        ),
  );
}
