import 'package:flutter/material.dart';
import 'package:flutter_gantt/flutter_gantt.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpGantt(
  WidgetTester tester,
  GanttActivitiesListWidth? listWidth, {
  TextDirection textDirection = TextDirection.ltr,
}) async {
  tester.view.physicalSize = const Size(1000, 600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: Gantt(
            startDate: DateTime(2026, 1, 1),
            activities: [
              GanttActivity(
                key: 'a',
                start: DateTime(2026, 1, 2),
                end: DateTime(2026, 1, 5),
                title: 'Activity',
              ),
            ],
            activitiesListWidth: listWidth,
          ),
        ),
      ),
    ),
  );
}

/// Measures the activities list column, which is not exported publicly.
double listWidthOf(WidgetTester tester) =>
    tester
        .getSize(
          find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == 'ActivitiesList',
          ),
        )
        .width;

void main() {
  group('Gantt.activitiesListWidth', () {
    testWidgets('uses the provided width', (tester) async {
      await pumpGantt(tester, const GanttActivitiesListWidth(width: 250));

      expect(listWidthOf(tester), 250);
    });

    testWidgets('keeps the flex layout when not configured', (tester) async {
      await pumpGantt(tester, null);

      expect(listWidthOf(tester), 200);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is MouseRegion && w.cursor == SystemMouseCursors.resizeColumn,
        ),
        findsNothing,
      );
    });

    testWidgets('dragging the edge resizes and reports the new width', (
      tester,
    ) async {
      final changes = <double>[];
      await pumpGantt(
        tester,
        GanttActivitiesListWidth(width: 250, onChanged: changes.add),
      );

      await tester.dragFrom(const Offset(250, 300), const Offset(100, 0));
      await tester.pumpAndSettle();

      expect(listWidthOf(tester), closeTo(350, 1));
      expect(changes, hasLength(1));
      expect(changes.single, closeTo(350, 1));
    });

    testWidgets('clamps the width to the configured bounds', (tester) async {
      final changes = <double>[];
      await pumpGantt(
        tester,
        GanttActivitiesListWidth(
          width: 250,
          minWidth: 150,
          maxWidth: 400,
          onChanged: changes.add,
        ),
      );

      await tester.dragFrom(const Offset(250, 300), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(listWidthOf(tester), 150);

      await tester.dragFrom(const Offset(150, 300), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(listWidthOf(tester), 400);
      expect(changes, <double>[150, 400]);
    });

    testWidgets('inverts the drag direction in RTL', (tester) async {
      await pumpGantt(
        tester,
        const GanttActivitiesListWidth(width: 250),
        textDirection: TextDirection.rtl,
      );

      // In RTL the list sits on the right: its edge is at 1000 - 250.
      await tester.dragFrom(const Offset(750, 300), const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(listWidthOf(tester), closeTo(350, 1));
    });
  });
}
