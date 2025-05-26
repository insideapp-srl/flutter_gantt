import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';
import '../utils/datetime.dart';
import 'controller_extension.dart';

extension _DayColorEx on DateTime {
  Color get dayColor =>
      (weekday == 6 || weekday == 7)
          ? Colors.black.withValues(alpha: .2)
          : Colors.transparent;
}

class CalendarGrid extends StatelessWidget {
  const CalendarGrid({super.key});

  @override
  Widget build(BuildContext context) => Consumer<GanttController>(
    builder:
        (context, c, child) => Column(
          children: [
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
            Expanded(
              child: Row(
                children: List.generate(c.days.length, (i) {
                  final day = c.days[i];
                  return Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: day.dayColor,
                            height: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Text(
                                '${day.day}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight:
                                day.isToday? FontWeight.bold:
                                FontWeight.normal,),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,

                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: double.infinity,
                          width: 1,
                          color:
                              (i < c.days.length - 1)
                                  ? Colors.grey
                                  : Colors.transparent,
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
