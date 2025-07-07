import 'package:flutter/material.dart';

import '../utils/datetime.dart';

/// An action that can be performed on a Gantt activity.
class GantActivityAction {
  /// The icon representing the action.
  final IconData icon;

  /// The callback when the action is triggered.
  final VoidCallback onTap;

  /// Optional tooltip text for the action.
  final String? tooltip;

  /// Creates an activity action with an icon, tap handler, and optional tooltip.
  const GantActivityAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });
}

/// Represents an activity in the Gantt chart.
///
/// Each activity has a start/end date, title, and optional styling properties.
/// Activities can be hierarchical with parent-child relationships.
class GantActivity<T> {
  /// Unique identifier for the activity.
  late String key;

  /// The start date of the activity.
  late DateTime start;

  /// The end date of the activity.
  late DateTime end;

  /// The title text of the activity (mutually exclusive with [titleWidget]).
  final String? title;

  /// A custom widget for the activity title (mutually exclusive with [title]).
  final Widget? titleWidget;

  /// Alternative title for the list view (optional).
  final String? listTitle;

  /// Custom widget for the list view title (optional).
  final Widget? listTitleWidget;

  /// The tooltip message (mutually exclusive with [tooltipWidget]).
  final String? tooltipMessage;

  /// A custom widget for the tooltip (mutually exclusive with [tooltipMessage]).
  final Widget? tooltipWidget;

  /// The text style for the activity title.
  final TextStyle? titleStyle;

  /// An optional icon to display with the title.
  final Widget? iconTitle;

  /// The segments that make up this activity.
  final List<GantActivitySegment>? segments;

  /// Child activities that are hierarchically under this one.
  final List<GantActivity>? children;

  /// Actions that can be performed on this activity.
  final List<GantActivityAction>? actions;

  /// Callback when the activity cell is tapped.
  final Function(GantActivity activity)? onCellTap;

  /// Builder function for custom cell rendering.
  final Widget Function(DateTime cellDate)? cellBuilder;

  /// The color of the activity cell.
  final Color? color;

  /// Whether to show the activity cell.
  final bool showCell;

  /// Optional custom data associated with the activity.
  final T? data;

  GantActivity? _parent;

  /// The parent activity, if this is a child activity.
  GantActivity? get parent => _parent;

  /// Creates a [GantActivity] with the specified properties.
  ///
  /// Throws an [AssertionError] if:
  /// - Start date is after end date
  /// - Both [title] and [titleWidget] are provided or both are null
  /// - Both [tooltipMessage] and [tooltipWidget] are provided or both are null
  /// - Any segment dates fall outside the activity dates
  /// - Any child activity dates fall outside this activity's dates
  GantActivity({
    required this.key,
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
    this.data,
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
    if (children != null) {
      for (final child in children!) {
        assert(
          child.start.isDateBetween(this.start, this.end) &&
              child.end.isDateBetween(this.start, this.end),
        );
        child._parent = this;
      }
    }
  }

  /// The duration of the activity in days.
  int get daysDuration => end.diffInDays(start) + 1;

  @override
  String toString() => title ?? super.toString();

  /// Gets a flat list of this activity and all its descendants.
  List<GantActivity> get plainList => [this, ...children?.plainList ?? []];
}

/// Extension methods for working with lists of [GantActivity].
extension GantActivityListExtension on List<GantActivity> {
  /// Gets a flat list of all activities and their descendants.
  List<GantActivity> get plainList {
    final as = <GantActivity>[];
    for (var a in this) {
      as.addAll(a.plainList);
    }
    return as;
  }

  /// Finds an activity by its key in the flattened list.
  GantActivity? getFromKey(String key) {
    final i = plainList.indexWhere((e) => e.key == key);
    return i < 0 ? null : plainList[i];
  }
}

/// A segment of a Gantt activity.
///
/// Activities can be divided into segments to show progress or phases.
class GantActivitySegment {
  /// The start date of the segment.
  late DateTime start;

  /// The end date of the segment.
  late DateTime end;

  /// The title of the segment.
  final String title;

  /// The description of the segment.
  final String description;

  /// Callback when the segment is tapped.
  final Function(GantActivity activity)? onTap;

  /// The color of the segment.
  final Color? color;

  /// Creates a [GantActivitySegment].
  ///
  /// Throws an [AssertionError] if start date is after end date.
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

  @override
  String toString() => title;
}
