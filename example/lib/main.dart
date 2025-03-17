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
  GanttController controller = GanttController(daysViews: 20);

  List<WorkOrders> workOrders = [

    WorkOrders(
      start: DateTime(2025, 1, 15),
      end: DateTime(2025, 1, 25),
      workHours: 80,
      title: 'Task 1',
      description: 'Description 1',
      onTap: (workOrders) {
        // ToDo
      },
    ),
    WorkOrders(
      start: DateTime(2025, 1, 23),
      end: DateTime(2025, 1, 30),
      workHours: 88,
      title: 'Task 2, titolo lungo',
      description: 'Description 2',
    ),
    WorkOrders(
      start: DateTime(2025, 3, 1),
      end: DateTime(2025, 3, 17),
      workHours: 200,
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
              workOrders: workOrders,
            ),
          ),
        ],
      ),
    );
}


