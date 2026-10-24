import 'package:flutter/material.dart';
import 'package:flutter_gantt/flutter_gantt.dart';
import 'package:flutter_gantt/src/widgets/controller_extension.dart';
import 'package:flutter_test/flutter_test.dart';

/// First visible day of every chart in these tests.
final DateTime start = DateTime.utc(2026, 1, 5);

/// Inset of the progress track from the real start and end of an activity.
const double inset = 8;

/// Pumps a 10-day chart with [activities] and returns its controller.
Future<GanttController> pumpGantt(
  WidgetTester tester,
  List<GanttActivity> activities, {
  double? collapseActionsBelowWidth,
}) async {
  tester.view.physicalSize = const Size(1200, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final controller = GanttController(startDate: start, daysViews: 10);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Gantt(
          controller: controller,
          activities: activities,
          collapseActionsBelowWidth: collapseActionsBelowWidth,
        ),
      ),
    ),
  );
  await tester.pump();
  return controller;
}

/// An activity from [startDay] to [endDay], counted from [start].
GanttActivity activity(int startDay, int endDay, {double? progress}) =>
    GanttActivity(
      key: '$startDay-$endDay',
      title: 'Activity',
      start: start.add(Duration(days: startDay)),
      end: start.add(Duration(days: endDay)),
      progress: progress,
    );

/// The resize edges of the cells.
Finder get edges => find.byWidgetPredicate(
  (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeLeftRight,
);

/// The progress track (first) and line (second) of the cells.
List<Positioned> get progressBars => find
    .descendant(
      of: find.byType(GanttCell),
      matching: find.byWidgetPredicate((w) => w is Positioned && w.height == 3),
    )
    .evaluate()
    .map((e) => e.widget as Positioned)
    .toList();

void main() {
  group('resize edges', () {
    testWidgets('are both drawn on a fully visible activity', (tester) async {
      await pumpGantt(tester, [activity(2, 5)]);
      expect(edges, findsNWidgets(2));
    });

    testWidgets('are not drawn on a side cut by the visible range', (
      tester,
    ) async {
      await pumpGantt(tester, [activity(-3, 4)]);
      expect(edges, findsOneWidget);
    });

    testWidgets('are not drawn when both sides are cut', (tester) async {
      await pumpGantt(tester, [activity(-2, 12)]);
      expect(edges, findsNothing);
    });
  });

  group('progress track and line', () {
    testWidgets('are inset from the real start and end of the activity', (
      tester,
    ) async {
      final controller = await pumpGantt(tester, [
        activity(2, 5, progress: 0.5),
      ]);
      final day = controller.dayColumnWidth;
      final [track, line] = progressBars;
      expect(track.left, inset);
      expect(track.width, closeTo(4 * day - 2 * inset, 0.001));
      expect(line.left, inset);
      expect(line.width, closeTo((4 * day - 2 * inset) * 0.5, 0.001));
    });

    testWidgets('continue beyond the grid edge when the start is hidden', (
      tester,
    ) async {
      final controller = await pumpGantt(tester, [
        activity(-3, 4, progress: 0.25),
      ]);
      final day = controller.dayColumnWidth;
      final [track, line] = progressBars;
      // 3 days hidden: the track starts left of the cell, which clips it.
      expect(track.left, closeTo(inset - 3 * day, 0.001));
      expect(track.width, closeTo(8 * day - 2 * inset, 0.001));
      expect(line.left, track.left);
      expect(line.width, closeTo((8 * day - 2 * inset) * 0.25, 0.001));
    });

    testWidgets('show only the track at 0%', (tester) async {
      await pumpGantt(tester, [activity(2, 5, progress: 0)]);
      expect(progressBars, hasLength(1));
    });

    testWidgets('are not drawn without progress', (tester) async {
      await pumpGantt(tester, [activity(2, 5)]);
      expect(progressBars, isEmpty);
    });

    testWidgets('cap the line at the track above 100%', (tester) async {
      await pumpGantt(tester, [activity(2, 5, progress: 1.5)]);
      final [track, line] = progressBars;
      expect(line.width, track.width);
    });
  });

  testWidgets('the "more" menu asserts that its actions have a tooltip', (
    tester,
  ) async {
    await pumpGantt(tester, [
      GanttActivity(
        key: 'a',
        title: 'Activity',
        start: start,
        end: start.add(const Duration(days: 2)),
        actions: [
          GanttActivityAction(icon: Icons.edit, onTap: () {}),
          GanttActivityAction(icon: Icons.delete, onTap: () {}),
        ],
      ),
    ], collapseActionsBelowWidth: double.infinity);
    expect(tester.takeException(), isA<AssertionError>());
  });
}
