import 'package:flutter/material.dart';

import '../utils/datetime.dart';

/// An action that can be performed on a Gantt activity.
class GanttActivityAction {
  /// The icon representing the action.
  final IconData icon;

  /// The callback when the action is triggered.
  final VoidCallback onTap;

  /// Optional tooltip text for the action.
  final String? tooltip;

  /// Optional style for the action button.
  final ButtonStyle? style;

  /// Creates an activity action with an icon, tap handler, and optional tooltip.
  const GanttActivityAction({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.style,
  });
}

/// Represents an activity in the Gantt chart.
///
/// Each activity has a start/end date, title, and optional styling properties.
/// Activities can be hierarchical with parent-child relationships.
class GanttActivity<T> {
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

  /// The tooltip message.
  final String? tooltip;

  /// An optional icon to display with the title.
  final Widget? iconTitle;

  /// Child activities that are hierarchically under this one.
  final List<GanttActivity>? children;

  /// Actions that can be performed on this activity.
  final List<GanttActivityAction>? actions;

  /// Callback when the activity cell is tapped.
  final Function(GanttActivity activity)? onCellTap;

  /// Builder function for custom single cell rendering.
  final Widget Function(DateTime cellDate)? cellBuilder;

  /// The color of the activity cell.
  final Color? color;

  /// Whether to show the activity cell.
  final bool showCell;

  /// The share of the activity that is complete, from 0.0 to 1.0.
  ///
  /// Drawn by the default cell as a line along the bottom edge, over a track
  /// that spans the whole activity, so it reads as a progress bar. Track and
  /// line are inset 8px from the real start and end of the activity, in line
  /// with the title, and are measured on the whole activity: they stay in
  /// place while the visible range moves and, on a side cut by it, continue
  /// beyond the grid edge. Values above 1.0 draw a full line; 0.0 draws only
  /// the track. If `null` (the default), neither is drawn. Cells built with
  /// [builder] or [cellBuilder] do not draw it.
  final double? progress;

  /// The color of the [progress] line; the track uses it at 30% opacity.
  ///
  /// If `null`, white or black is used, whichever has the higher contrast
  /// against the cell, like the title text. A custom color is drawn as is, so
  /// its contrast against the cell is up to the caller.
  final Color? progressColor;

  /// Builder function for custom cell rendering.
  final Widget Function(GanttActivity activity)? builder;

  /// Optional custom data associated with the activity.
  final T? data;

  GanttActivity? _parent;

  /// The parent activity, if this is a child activity.
  GanttActivity? get parent => _parent;

  /// The limit of the start date of the activity.
  late DateTime? limitStart;

  /// The limit of the end date of the activity.
  late DateTime? limitEnd;

  /// Creates a [GanttActivity] with the specified properties.
  ///
  /// Throws an [AssertionError] if:
  /// - Start date is after end date
  /// - Only one between [title] and [titleWidget] must be provided
  /// - Any segment dates fall outside the activity dates
  /// - Any child activity dates fall outside this activity's dates
  GanttActivity({
    required this.key,
    required DateTime start,
    required DateTime end,
    this.title,
    this.titleWidget,
    this.listTitle,
    this.listTitleWidget,
    this.tooltip,
    this.iconTitle,
    this.children,
    this.onCellTap,
    this.cellBuilder,
    this.color,
    this.actions,
    this.showCell = true,
    this.progress,
    this.progressColor,
    this.builder,
    this.data,
    this.limitStart,
    this.limitEnd,
  }) : assert(
         start.toDate.isBeforeOrSame(end.toDate) &&
             ((title == null) != (titleWidget == null)) &&
             ((cellBuilder == null) || (builder == null)) &&
             ((listTitle == null) || (listTitleWidget == null)) &&
             (progress == null || progress >= 0),
       ) {
    this.start = start.toDate;
    this.end = end.toDate;
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
  List<GanttActivity> get plainList => [this, ...children?.plainList ?? []];

  bool validStartMoveToParent(int days) =>
      parent == null ||
      !parent!.showCell ||
      start.addDays(days).isAfterOrSame(parent!.start);

  bool validStartMoveToChildren(int days) =>
      (children?.isEmpty ?? true) == true ||
      start
          .addDays(days)
          .isBeforeOrSame(
            DateTimeEx.firstDateFromList(
              children!.map((e) => e.start).toList(),
            ),
          );

  bool validEndMoveToParent(int days) =>
      parent == null ||
      !parent!.showCell ||
      end.addDays(days).isBeforeOrSame(parent!.end);

  bool validEndMoveToChildren(int days) =>
      (children?.isEmpty ?? true) == true ||
      end
          .addDays(days)
          .isAfterOrSame(
            DateTimeEx.lastDateFromList(children!.map((e) => e.end).toList()),
          );

  bool validMoveToParent(int days) =>
      validStartMoveToParent(days) && validEndMoveToParent(days);

  bool validStartMove(int days) =>
      validStartMoveToParent(days) &&
      validStartMoveToChildren(days) &&
      (limitStart == null || start.addDays(days).isAfterOrSame(limitStart!));

  bool validEndMove(int days) =>
      validEndMoveToParent(days) &&
      validEndMoveToChildren(days) &&
      (limitEnd == null || end.addDays(days).isBeforeOrSame(limitEnd!));

  bool validMove(int days) => validStartMove(days) && validEndMove(days);
}

/// Extension methods for working with lists of [GanttActivity].
extension GanttActivityListExtension on List<GanttActivity> {
  /// Gets a flat list of all activities and their descendants.
  List<GanttActivity> get plainList {
    final as = <GanttActivity>[];
    for (var a in this) {
      as.addAll(a.plainList);
    }
    return as;
  }

  /// Finds an activity by its key in the flattened list.
  GanttActivity? getFromKey(String key) {
    final i = plainList.indexWhere((e) => e.key == key);
    return i < 0 ? null : plainList[i];
  }
}
