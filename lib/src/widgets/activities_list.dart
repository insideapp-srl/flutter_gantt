import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

class ActivitiesList extends StatelessWidget {
  final List<GantActivity> activities;
  final ScrollController? controller;

  const ActivitiesList({super.key, required this.activities, this.controller});

  List<Widget> getItems(
    List<GantActivity> activities,
    GanttTheme theme, {
    int nested = 0,
  }) => List.generate(
    activities.length,
    (index) => Padding(
      padding: EdgeInsets.only(
        top: theme.rowPadding + (nested == 0?theme.rowsGroupPadding:0),
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
                Expanded(
                  child: Tooltip(
                    message: activities[index].title,
                    child: Text(
                      activities[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
