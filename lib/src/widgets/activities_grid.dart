import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

/// Displays the activities grid portion of the Gantt chart.
///
/// The grid shows activity rows with their durations and optional child activities
/// in a timeline view. It synchronizes scrolling with the [ActivitiesList] widget.
class ActivitiesGrid extends StatelessWidget {
  /// The list of [GanttActivity] items to display in the grid.
  ///
  /// This list can contain parent activities with nested child activities.
  final List<GanttActivity> activities;

  /// Optional [ScrollController] to synchronize scrolling with other widgets.
  ///
  /// Typically used with [LinkedScrollControllerGroup] to sync with the activity list.
  final ScrollController? controller;

  /// Creates an [ActivitiesGrid] widget.
  ///
  /// [activities] must not be null and should contain at least one activity.
  const ActivitiesGrid({super.key, required this.activities, this.controller});

  /// Recursively builds widgets for activities and their children.
  ///
  /// [activities] - The list of activities to build widgets for
  /// [theme] - The current [GanttTheme] for styling
  /// [nested] - The current nesting level (used for indentation)
  List<Widget> getItems(
    List<GanttActivity> activities,
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
