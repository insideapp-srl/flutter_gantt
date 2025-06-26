import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

/// Displays the activities grid portion of the Gantt chart.
///
/// Shows activity rows with their durations and optional child activities.
class ActivitiesGrid extends StatelessWidget {
  /// The list of activities to display
  final List<GantActivity> activities;

  /// Optional scroll controller for the grid
  final ScrollController? controller;

  /// Creates an activities grid with required activities
  const ActivitiesGrid({super.key, required this.activities, this.controller});

  /// Recursively builds widgets for activities and their children
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
            ...getItems(activities[index].children!, theme, nested: nested + 1),
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
