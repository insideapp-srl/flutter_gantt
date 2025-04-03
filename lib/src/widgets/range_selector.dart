import 'package:flutter/material.dart';

import 'controller.dart';

class GanttRangeSelector extends StatelessWidget {
  final GanttController controller;

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
