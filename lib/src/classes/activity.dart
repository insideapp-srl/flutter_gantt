import 'package:flutter/material.dart';

import '../utils/datetime.dart';

class GantActivityAction {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  GantActivityAction({required this.icon, required this.onTap, this.tooltip});
}

class GantActivity {
  late DateTime start;
  late DateTime end;
  final String? title;
  final Widget? titleWidget;
  final String? listTitle;
  final Widget? listTitleWidget;
  final String? tooltipMessage;
  final Widget? tooltipWidget;
  final TextStyle? titleStyle;
  final Widget? iconTitle;
  final List<GantActivitySegment>? segments;
  final List<GantActivity>? children;
  final List<GantActivityAction>? actions;
  final Function(GantActivity activity)? onCellTap;
  final Widget Function(DateTime cellDate)? cellBuilder;
  final Color? color;
  final bool showCell;

  GantActivity({
    required DateTime start,
    required DateTime end,
    this.title,
    this.titleWidget,
    this.listTitle,
    this.listTitleWidget,
    this.tooltipMessage,
    this.tooltipWidget,
    this.titleStyle,
    this.iconTitle,
    this.segments,
    this.children,
    this.onCellTap,
    this.cellBuilder,
    this.color,
    this.actions,
    this.showCell = true,
  }) : assert(
         start.toDate.isBeforeOrSame(end.toDate) &&
             ((tooltipMessage == null) != (tooltipWidget == null)) &&
             ((title == null) != (titleWidget == null)) &&
             ((listTitle == null) || (listTitleWidget == null)),
       ) {
    this.start = start.toDate;
    this.end = end.toDate;
    if (segments != null) {
      for (final segment in segments!) {
        assert(
          segment.start.isDateBetween(this.start, this.end) &&
              segment.end.isDateBetween(this.start, this.end),
        );
      }
    }
    //TODO
    // if (children != null) {
    //   for (final child in children!) {
    //     assert(
    //       child.start.isDateBetween(this.start, this.end) &&
    //           child.end.isDateBetween(this.start, this.end),
    //     );
    //   }
    // }
  }

  int get daysDuration => end.diffInDays(start) + 1;
}

class GantActivitySegment {
  late DateTime start;
  late DateTime end;
  final String title;
  final String description;
  final Function(GantActivity activity)? onTap;
  final Color? color;

  GantActivitySegment({
    required DateTime start,
    required DateTime end,
    required this.title,
    required this.description,
    this.onTap,
    this.color,
  }) : assert(start.toDate.isBeforeOrSame(end.toDate)) {
    this.start = start.toDate;
    this.end = end.toDate;
  }
}
