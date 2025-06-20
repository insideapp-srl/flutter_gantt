import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

/// Displays the list of activity names on the left side of the Gantt chart.
class ActivitiesList extends StatelessWidget {
  /// The list of activities to display
  final List<GantActivity> activities;

  /// Optional scroll controller for the list
  final ScrollController? controller;

  /// Creates an activities list with required activities
  const ActivitiesList({super.key, required this.activities, this.controller});

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
        left: 8.0 * (nested + 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: theme.cellHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (activities[index].iconTitle != null)
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: activities[index].iconTitle!,
                  ),
                Expanded(
                  child:
                      activities[index].titleWidget ??
                      Tooltip(
                        message: activities[index].title,
                        child: Text(
                          activities[index].title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: activities[index].titleStyle,
                        ),
                      ),
                ),
                if (activities[index].actions?.isNotEmpty == true)
                  Row(
                    children:
                        activities[index].actions!.map((e) {
                          final child = IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: e.onTap,
                            icon: Icon(e.icon, size: theme.cellHeight * 0.8),
                          );
                          return e.tooltip != null
                              ? Tooltip(message: e.tooltip, child: child)
                              : child;
                        }).toList(),
                  ),
              ],
            ),
          ),
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
