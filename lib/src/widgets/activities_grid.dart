import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

class ActivitiesGrid extends StatelessWidget {
  final List<GantActivity> activities;
  final ScrollController? controller;

  const ActivitiesGrid({
    super.key,
    required this.activities,
    this.controller,
  });

  @override
  Widget build(BuildContext context) => Consumer<GanttTheme>(
    builder:
        (context, theme, child) => Padding(
          padding: EdgeInsets.only(
            top: theme.headerHeight + theme.rowsGroupPadding,
          ),
          child: ListView(controller: controller,
            children: List.generate(
              activities.length,
              (index) => Padding(
                padding: EdgeInsets.only(top: theme.rowPadding),
                child: GanttActivityRow(activity: activities[index]),
              ),
            ),
          ),
        ),
  );
}
