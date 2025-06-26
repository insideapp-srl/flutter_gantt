import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_gantt/flutter_gantt.dart';

void main() {
  runApp(const MyApp());
}

/// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Gantt Demo',
        scrollBehavior: AppCustomScrollBehavior(),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.tealAccent,
            brightness: Brightness.dark,
          ),
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.tealAccent,
            brightness: Brightness.light,
          ),
        ),
        home: const MyHomePage(title: 'Flutter Gantt'),
      );
}

/// Enable scrolling with various input devices
class AppCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}

/// Home page widget
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final GanttController controller;
  late final List<GantActivity> _activities;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final monthLater = now.add(const Duration(days: 30));

    controller =
        GanttController(startDate: now.subtract(const Duration(days: 14)));

    controller.addOnMoveListener(_onActivityMoved);
    _activities = [
      // ✅ Main activity with children inside range
      GantActivity(
        key: 'task1',
        start: now.subtract(const Duration(days: 3)),
        end: now.add(const Duration(days: 6)),
        title: 'Main Task',
        tooltipMessage: 'WO-1001 | Top-level task across multiple days',
        color: const Color(0xFF4DB6AC),
        cellBuilder: (cellDate) => Container(
          color: const Color(0xFF00796B),
          child: Center(
            child: Text(
              cellDate.day.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        actions: [
          GantActivityAction(
            icon: Icons.visibility,
            tooltip: 'View',
            onTap: () => debugPrint('Viewing WO-1001'),
          ),
          GantActivityAction(
            icon: Icons.edit,
            tooltip: 'Edit',
            onTap: () => debugPrint('Editing WO-1001'),
          ),
          GantActivityAction(
            icon: Icons.delete,
            tooltip: 'Delete',
            onTap: () => debugPrint('Deleting WO-1001'),
          ),
        ],
        children: [
          GantActivity(
            key: 'task1.sub1',
            start: now.subtract(const Duration(days: 2)),
            end: now.add(const Duration(days: 1)),
            title: 'Subtask 1',
            tooltipMessage: 'WO-1001-1 | Subtask',
            color: const Color(0xFF81C784),
            actions: [
              GantActivityAction(
                icon: Icons.check,
                tooltip: 'Mark done',
                onTap: () => debugPrint('Marking subtask done'),
              ),
            ],
          ),
          GantActivity(
            key: 'task1.sub2',
            start: now,
            end: now.add(const Duration(days: 5)),
            title: 'Subtask 2',
            tooltipMessage: 'WO-1001-2 | Subtask with nested children',
            color: const Color(0xFF9575CD),
            actions: [
              GantActivityAction(
                icon: Icons.add,
                tooltip: 'Add nested task',
                onTap: () => debugPrint('Add nested to WO-1001-2'),
              ),
            ],
            children: [
              GantActivity(
                key: 'task1.sub2.subA',
                start: now.add(const Duration(days: 1)),
                end: now.add(const Duration(days: 3)),
                title: 'Nested Subtask A',
                tooltipMessage: 'WO-1001-2A | Second-level task',
                color: const Color(0xFFBA68C8),
                actions: [
                  GantActivityAction(
                    icon: Icons.edit,
                    tooltip: 'Edit',
                    onTap: () => debugPrint('Editing nested A'),
                  ),
                ],
              ),
              GantActivity(
                key: 'task1.sub2.subB',
                start: now.add(const Duration(days: 2)),
                end: now.add(const Duration(days: 4)),
                title: 'Nested Subtask B',
                tooltipMessage: 'WO-1001-2B | Continued',
                color: const Color(0xFFFF8A65),
                actions: [
                  GantActivityAction(
                    icon: Icons.delete,
                    tooltip: 'Delete',
                    onTap: () => debugPrint('Deleting nested B'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ✅ Standalone task near today
      GantActivity(
        key: 'task2',
        start: now.add(const Duration(days: 1)),
        end: now.add(const Duration(days: 8)),
        title: 'Independent Task',
        tooltipMessage: 'A separate task',
        color: const Color(0xFF64B5F6),
      ),

      // ✅ Activity from one month ago
      GantActivity(
        key: 'task3',
        start: monthAgo.subtract(const Duration(days: 3)),
        end: monthAgo.add(const Duration(days: 3)),
        title: 'Archived Task',
        tooltipMessage: 'Task from one month ago',
        color: const Color(0xFF90A4AE), // Blue grey
      ),

      // ✅ Activity a few days ago
      GantActivity(
        key: 'task4',
        start: now.subtract(const Duration(days: 10)),
        end: now.subtract(const Duration(days: 4)),
        title: 'Older Task',
        tooltipMessage: 'Past task',
        color: const Color(0xFFBCAAA4), // Light brown
      ),

      // ✅ Future activity
      GantActivity(
        key: 'task5',
        start: monthLater.subtract(const Duration(days: 5)),
        end: monthLater.add(const Duration(days: 2)),
        title: 'Planned Future Task',
        tooltipMessage: 'Future scheduled task',
        color: const Color(0xFF7986CB), // Indigo
      ),

      // ✅ Long-term task
      GantActivity(
        key: 'task6',
        start: now.subtract(const Duration(days: 10)),
        end: monthLater,
        title: 'Ongoing Project',
        tooltipMessage: 'Spanning multiple weeks',
        color: const Color(0xFF4FC3F7), // Sky blue
      ),
    ];
  }

  void _onActivityMoved(activity, days) =>
      debugPrint('$activity was moved by $days days (Event on controller)');

  @override
  void dispose() {
    controller.removeOnMoveListener(_onActivityMoved);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            GanttRangeSelector(controller: controller),
            Expanded(
              child: Gantt(
                theme: GanttTheme.of(context),
                controller: controller,
                activitiesAsync: (startDate, endDate, activity) async =>
                    _activities,
                holidaysAsync: (startDate, endDate, holidays) async {
                  final currentYear = DateTime.now().year;
                  return <GantDateHoliday>[
                    GantDateHoliday(
                      date: DateTime(currentYear, 1, 1),
                      holiday: 'New Year\'s Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 3, 8),
                      holiday: 'International Women\'s Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 5, 1),
                      holiday: 'International Workers\' Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 6, 5),
                      holiday: 'World Environment Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 10, 1),
                      holiday: 'International Day of Older Persons',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 10, 24),
                      holiday: 'United Nations Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 11, 11),
                      holiday: 'Remembrance Day / Armistice Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 12, 25),
                      holiday: 'Christmas Day',
                    ),
                    GantDateHoliday(
                      date: DateTime(currentYear, 12, 31),
                      holiday: 'New Year\'s Eve',
                    ),
                  ];
                },
                onActivityMoved: (activity, days) {
                  debugPrint('$activity was moved by $days days');
                  _activities.getFromKey(activity.key)!.start =
                      activity.start.add(Duration(days: days));
                  _activities.getFromKey(activity.key)!.end =
                      activity.end.add(Duration(days: days));
                  controller.update();
                },
              ),
            ),
          ],
        ),
      );
}
