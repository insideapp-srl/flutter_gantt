import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';
import '../utils/datetime.dart';
import 'controller_extension.dart';

/// Displays the calendar grid portion of the Gantt chart.
///
/// Shows month headers and day cells with weekend/holiday highlighting.
/// This grid appears above the activities grid to provide date context.
class CalendarGrid extends StatelessWidget {
  /// The list of holidays to highlight in the calendar.
  ///
  /// Holidays will be displayed with special background color and tooltips.
  final List<GantDateHoliday>? holidays;

  /// Creates a [CalendarGrid] widget.
  ///
  /// [holidays] is optional and can be null if no holidays need to be shown.
  const CalendarGrid({super.key, this.holidays});

  /// Gets the background color for a specific date based on theme and holidays.
  ///
  /// Returns:
  /// - [GanttTheme.holidayColor] for holidays
  /// - [GanttTheme.weekendColor] for weekends
  /// - [Colors.transparent] for normal weekdays
  Color getDayColor(GanttTheme theme, DateTime date) {
    if ((holidays ?? []).map((e) => e.date).contains(date)) {
      return theme.holidayColor;
    }
    if (date.isWeekend) {
      return theme.weekendColor;
    }
    return Colors.transparent;
  }

  /// Gets the holiday name for a specific date, if any.
  ///
  /// Returns the holiday name if the date matches a holiday in [holidays],
  /// otherwise returns null.
  String? getDayHoliday(DateTime date) =>
      (holidays ?? [])
          .where((e) => e.date.isAtSameMomentAs(date))
          .firstOrNull
          ?.holiday;

  @override
  Widget build(BuildContext context) => Consumer<GanttController>(
    builder:
        (context, c, child) => Column(
          children: [
            // Month headers row
            Builder(
              builder: (context) {
                final months = c.months.entries.toList();
                return Row(
                  children: List.generate(months.length, (i) {
                    final month = months[i];
                    return Expanded(
                      flex: month.value,
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                month.key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            color:
                                (i < months.length - 1)
                                    ? Colors.grey
                                    : Colors.transparent,
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  }),
                );
              },
            ),
            // Days grid
            Expanded(
              child: Row(
                children: List.generate(c.days.length, (i) {
                  final day = c.days[i];
                  final holiday = getDayHoliday(day);
                  final child = Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          day.isToday
                              ? context.watch<GanttTheme>().todayBackgroundColor
                              : null,
                    ),
                    child: Text(
                      '${day.day}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            day.isToday
                                ? context.watch<GanttTheme>().todayTextColor
                                : null,
                        fontWeight:
                            day.isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  );
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: getDayColor(
                              context.watch<GanttTheme>(),
                              day,
                            ),
                            height: double.infinity,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
                                child:
                                    holiday != null
                                        ? Tooltip(
                                          message: holiday,
                                          child: child,
                                        )
                                        : child,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: double.infinity,
                          width: 1,
                          color:
                              c.dateToHighlight(day)
                                  ? context.watch<GanttTheme>().defaultCellColor
                                  : Colors.grey,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
  );
}
