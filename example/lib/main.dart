import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_gantt/flutter_gantt.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        scrollBehavior: AppCustomScrollBehavior(),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Gantt'),
      );
}

class AppCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GanttController controller =
      GanttController(startDate: DateTime(2025, 3, 30));

  final List<GantActivity> _activities = [
    GantActivity(
      start: DateTime(2025, 3, 30),
      end: DateTime(2025, 4, 12),
      title: 'Task 1',
      description: 'Description 1',
     cellBuilder: (cellDate) => Container(
        color: Colors.blue,
        child: Text(cellDate.day.toString()),
      ),


      onCellTap: (activity) {
        // ToDo
      },
      actions: [
        GantActivityAction(
          icon: Icons.add,
          onTap: () {},
        ),
        GantActivityAction(
          icon: Icons.delete,
          onTap: () {},
          tooltip: 'Delete',
        ),
      ],
      segments: [
        /*
        GantActivitySegment(
          start: DateTime(2025, 4, 15),
          end: DateTime(2025, 4, 16),
          title: 'title',
          description: 'description',
        )

         */
      ],
      children: [
        GantActivity(
          start: DateTime(2025, 3, 30),
          end: DateTime(2025, 4, 12),
          title: 'Task 2, titolo lungo',
          description: 'Description 2',
          color: Colors.green,
          actions: [
            GantActivityAction(
              icon: Icons.add,
              onTap: () {},
            ),
          ],
        ),
        GantActivity(
          start: DateTime(2025, 3, 30),
          end: DateTime(2025, 4, 12),
          title: 'Task 3, Ciaone',
          description: 'Description 2',
          color: Colors.green,
          children: [
            GantActivity(
              start: DateTime(2025, 4, 1),
              end: DateTime(2025, 4, 12),
              title: 'Task 2, titolo lungo',
              description: 'Description 2',
              color: Colors.redAccent,
              actions: [
                GantActivityAction(
                  icon: Icons.add,
                  onTap: () {},
                ),
              ],
            ),
            GantActivity(
              start: DateTime(2025, 4, 2),
              end: DateTime(2025, 4, 11),
              title: 'Task 3, Ciaone',
              description: 'Description 2',
              color: Colors.redAccent,
            ),
          ],
        ),
      ],
    ),
    GantActivity(
      start: DateTime(2025, 4, 9),
      end: DateTime(2025, 4, 23),
      title: 'Task 2, titolo lungo',
      description: 'Description 2',
      actions: [
        GantActivityAction(
          icon: Icons.add,
          onTap: () {},
        ),
      ],
    ),
    GantActivity(
      start: DateTime(2025, 3, 28),
      end: DateTime(2025, 4, 17),
      title: 'Task 3, Ciaone',
      description: 'Description 2',
    ),
  ];

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
                controller: controller,
                //startDate: DateTime.now().subtract(Duration(days: 60)),
                //daysViews: 30,
                activitiesAsync: (startDate, endDate, activity) async =>
                    _activities,
                //activities: _activities,
                holidays: [
                  GantDateHoliday(
                      date: DateTime(2025, 12, 25), holiday: 'Natale')
                ],
              ),
            ),
          ],
        ),
      );
}
