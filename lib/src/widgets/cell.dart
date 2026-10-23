import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../classes/activity.dart';
import '../classes/theme.dart';
import '../utils/color.dart';
import '../utils/datetime.dart';
import '../widgets/controller_extension.dart';

/// A single cell representing an activity's duration in the Gantt chart.
///
/// Each cell visually represents the duration of an activity in the timeline.
/// Supports hover effects, tap actions, and custom styling.
class GanttCell extends StatefulWidget {
  /// The [GanttActivity] this cell represents.
  final GanttActivity activity;

  /// Creates a [GanttCell] for the specified activity.
  ///
  /// [activity] must not be null.
  const GanttCell({super.key, required this.activity});

  @override
  State<GanttCell> createState() => _GanttCellState();
}

class _GanttCellState extends State<GanttCell> {
  bool mouseOver = false;

  /// Gets the cell color, falling back to theme's default if not specified.
  ///
  /// Returns the activity's custom color if set, otherwise returns the
  /// default cell color from the current [GanttTheme].
  Color get color => widget.activity.cellColor(context.watch<GanttTheme>());

  /// Horizontal padding of the title, also the inset of the progress track
  /// from the cell edges: the track lines up with the title and stays clear of
  /// the resize edges.
  static const double _padding = 8.0;

  /// Width of the progress track: the whole activity, not only its visible
  /// part, without the insets at its real start and end; zero or less when
  /// the activity is too short to draw it.
  double get trackWidth =>
      context.watch<GanttActivityCtrl>().dayColumnWidth *
          widget.activity.daysDuration -
      2 * _padding;

  /// Left edge of the progress track in the cell.
  ///
  /// Negative when the start of the activity is before the visible range: the
  /// track and the line then continue beyond the grid edge, where the cell
  /// clips them, so only the title sticks to the edge.
  double get trackLeft {
    final ctrl = context.watch<GanttActivityCtrl>();
    final hiddenDays =
        widget.activity.start.isBefore(ctrl.startDate)
            ? ctrl.startDate.diffInDays(widget.activity.start)
            : 0;
    return _padding - ctrl.dayColumnWidth * hiddenDays;
  }

  /// Width of the [GanttActivity.progress] line, as a share of [trackWidth].
  double get progressWidth {
    final progress = widget.activity.progress;
    if (progress == null || progress <= 0 || trackWidth <= 0) return 0;
    return trackWidth * progress.clamp(0.0, 1.0);
  }

  /// Gets the title text color, white or black against the cell (see
  /// [GanttActivityColors.onCellColor]). Only text without a color of its own
  /// takes it.
  Color get textColor =>
      widget.activity.onCellColor(context.watch<GanttTheme>());

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => widget.activity.onCellTap?.call(widget.activity),
    child: MouseRegion(
      onEnter: (event) => setState(() => mouseOver = true),
      onExit: (event) => setState(() => mouseOver = false),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft:
                context.watch<GanttActivityCtrl>().cellsNotVisibleBefore
                    ? Radius.zero
                    : Radius.circular(context.watch<GanttTheme>().cellRounded),
            bottomRight:
                context.watch<GanttActivityCtrl>().cellsNotVisibleAfter
                    ? Radius.zero
                    : Radius.circular(context.watch<GanttTheme>().cellRounded),
          ),
          color: color.withValues(alpha: color.a * (mouseOver ? 0.7 : 1)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _padding),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: textColor),
                child:
                    widget.activity.titleWidget ??
                    Text(
                      widget.activity.title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              ),
            ),
            // The track spans the whole activity but the insets, so the line
            // reads as a progress bar; it is drawn at 0% too.
            if (widget.activity.progress != null && trackWidth > 0)
              Positioned(
                left: trackLeft,
                width: trackWidth,
                bottom: 2,
                height: 3,
                child: ColoredBox(
                  color: widget.activity.trackColor(
                    context.watch<GanttTheme>(),
                  ),
                ),
              ),
            if (progressWidth > 0)
              Positioned(
                left: trackLeft,
                bottom: 2,
                height: 3,
                width: progressWidth,
                child: ColoredBox(
                  color: widget.activity.progressLineColor(
                    context.watch<GanttTheme>(),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
