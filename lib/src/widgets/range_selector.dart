import 'package:flutter/material.dart';

import 'controller.dart';

/// Provides navigation controls for the Gantt chart timeline.
///
/// Displays previous/next buttons to scroll through the timeline.
class GanttRangeSelector extends StatelessWidget {
  /// The [GanttController] to manipulate the timeline.
  final GanttController controller;

  /// Creates a [GanttRangeSelector] for the specified controller.
  const GanttRangeSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        onPressed: () => controller.prev(),
        icon: Icon(Icons.navigate_before),
      ),
      IconButton(
        onPressed: () => controller.next(),
        icon: Icon(Icons.navigate_next),
      ),
    ],
  );
}
