import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

class ActivitiesGrid extends StatelessWidget {
  final List<GantActivity> activities;
  final ScrollController? controller;

  const ActivitiesGrid({super.key, required this.activities, this.controller});

  List<Widget> getItems(
    List<GantActivity> activities,
    GanttTheme theme, {
    int nested = 0,
  }) => List.generate(
    activities.length,
    (index) => Padding(
      padding: EdgeInsets.only(
        top: theme.rowPadding + (nested == 0 ? theme.rowsGroupPadding : 0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GanttActivityRow(activity: activities[index]),
          if (activities[index].children?.isNotEmpty == true)
            ...getItems(
              activities[index].children!,
              theme,
              nested: nested + 1,
            ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Consumer<GanttTheme>(
    builder:
        (context, theme, child) => Padding(
          padding: EdgeInsets.only(top: theme.headerHeight),
          child: ListView(
            controller: controller,
            children: getItems(activities, theme),
          ),
        ),
  );
}
