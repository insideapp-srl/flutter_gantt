import 'package:flutter/foundation.dart';

/// Configures a user-resizable width (in logical pixels) for the activities
/// list column of the `Gantt` chart.
///
/// The Gantt chart does not persist the width: provide the stored value
/// through [width] and save the new one from [onChanged].
class GanttActivitiesListWidth {
  /// The initial width of the activities list column.
  ///
  /// If `null`, the initial width is derived from the
  /// `activitiesListFlex`/`gridAreaFlex` ratio of the `Gantt` widget.
  /// Passing a different value on rebuild resets the current width.
  final double? width;

  /// The minimum width the column can be resized to (default: 100).
  final double minWidth;

  /// The maximum width the column can be resized to
  /// (default: [double.infinity]).
  ///
  /// The column is also always limited so that the grid area keeps
  /// at least one day column visible.
  final double maxWidth;

  /// Called with the new width when the user finishes resizing the column.
  ///
  /// Use it to persist the value and restore it later through [width].
  final ValueChanged<double>? onChanged;

  /// Creates a [GanttActivitiesListWidth] configuration.
  const GanttActivitiesListWidth({
    this.width,
    this.minWidth = 100,
    this.maxWidth = double.infinity,
    this.onChanged,
  }) : assert(minWidth >= 0 && minWidth <= maxWidth);
}
