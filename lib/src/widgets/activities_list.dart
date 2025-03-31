import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

class ActivitiesList extends StatelessWidget {
  final List<GantActivity> activities;

  const ActivitiesList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) => Consumer<GanttTheme>(
    builder:
        (context, theme, child) => Padding(
          padding: EdgeInsets.only(
            top: theme.headerHeight + theme.rowsGroupPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              activities.length,
              (index) => Padding(
                padding: EdgeInsets.only(top: theme.rowPadding, left: 8.0),
                child: SizedBox(
                  height: theme.cellHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //if (index > 0) Icon(Icons.keyboard_arrow_right),
                      //Icon(Icons.keyboard_arrow_down),
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
                              activities[index].actions!
                                  .map(
                                    (e) => IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: e.onTap,
                                      icon: Icon(
                                        e.icon,
                                        size: theme.cellHeight * 0.8,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
  );
}
