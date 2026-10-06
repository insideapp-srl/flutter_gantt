import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_gantt/flutter_gantt.dart';
import 'package:flutter_test/flutter_test.dart';

/// Yields to the event loop so pending fetch runs can make progress.
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('GanttController.fetch', () {
    late GanttController controller;
    late List<FlutterErrorDetails> reportedErrors;
    FlutterExceptionHandler? previousOnError;

    setUp(() {
      controller = GanttController(startDate: DateTime(2026, 1, 1));
      reportedErrors = <FlutterErrorDetails>[];
      previousOnError = FlutterError.onError;
      FlutterError.onError = reportedErrors.add;
    });

    tearDown(() {
      FlutterError.onError = previousOnError;
    });

    test('runs every listener once when no fetch is in flight', () async {
      final calls = <String>[];
      controller.addFetchListener(() => calls.add('sync'));
      controller.addFetchListener(() async => calls.add('async'));

      controller.fetch();
      await settle();

      expect(calls, <String>['sync', 'async']);
    });

    test('awaits async listeners before completing the run', () async {
      final gate = Completer<void>();
      var finished = false;
      controller.addFetchListener(() async {
        await gate.future;
        finished = true;
      });

      controller.fetch();
      await settle();
      expect(finished, isFalse);

      // A fetch arriving now must be treated as overlapping, which only holds
      // if the controller is actually awaiting the listener's future.
      var followUps = 0;
      controller.addFetchListener(() => followUps++);
      controller.fetch();
      await settle();
      expect(followUps, 0, reason: 'the first run is still in flight');

      gate.complete();
      await settle();
      expect(finished, isTrue);
      expect(followUps, 1);
    });

    test('coalesces overlapping fetches into a single follow-up run', () async {
      final gates = <Completer<void>>[];
      var runs = 0;
      controller.addFetchListener(() {
        runs++;
        final gate = Completer<void>();
        gates.add(gate);
        return gate.future;
      });

      controller.fetch();
      await settle();
      expect(runs, 1);

      // Three calls while the first run is in flight collapse into one rerun.
      controller.fetch();
      controller.fetch();
      controller.fetch();
      await settle();
      expect(runs, 1, reason: 'no second run may start in parallel');

      gates[0].complete();
      await settle();
      expect(runs, 2, reason: 'exactly one follow-up run, not three');

      gates[1].complete();
      await settle();
      expect(runs, 2);
    });

    test('accepts a new fetch once the queued rerun has drained', () async {
      final gates = <Completer<void>>[];
      var runs = 0;
      controller.addFetchListener(() {
        runs++;
        final gate = Completer<void>();
        gates.add(gate);
        return gate.future;
      });

      controller.fetch();
      await settle();
      controller.fetch();
      gates[0].complete();
      await settle();
      gates[1].complete();
      await settle();
      expect(runs, 2);

      controller.fetch();
      await settle();
      expect(runs, 3);
      gates[2].complete();
      await settle();
    });

    test(
      'does not throw when a listener is removed while a fetch is in flight',
      () async {
        // A Gantt widget disposed mid-fetch removes its own listener, which
        // used to blow up the run with a ConcurrentModificationError.
        final gate = Completer<void>();
        FutureOr<void> slowListener() => gate.future;
        var tailCalls = 0;

        controller.addFetchListener(slowListener);
        controller.addFetchListener(() => tailCalls++);

        controller.fetch();
        await settle();

        controller.removeFetchListener(slowListener);
        gate.complete();
        await settle();

        expect(reportedErrors, isEmpty);
        expect(tailCalls, 1, reason: 'the snapshot keeps the run intact');

        // The controller is still usable afterwards.
        controller.fetch();
        await settle();
        expect(tailCalls, 2);
      },
    );

    test(
      'does not throw when a listener is added while a fetch is in flight',
      () async {
        final gate = Completer<void>();
        var lateCalls = 0;
        controller.addFetchListener(() => gate.future);

        controller.fetch();
        await settle();

        controller.addFetchListener(() => lateCalls++);
        gate.complete();
        await settle();

        expect(reportedErrors, isEmpty);
        expect(lateCalls, 0, reason: 'not part of the run already started');

        controller.fetch();
        await settle();
        expect(lateCalls, 1);
      },
    );

    test('stays usable after a listener throws', () async {
      var calls = 0;
      controller.addFetchListener(() async {
        calls++;
        throw StateError('network down');
      });

      controller.fetch();
      await settle();
      expect(calls, 1);

      controller.fetch();
      await settle();
      expect(
        calls,
        2,
        reason: 'a failed fetch must not wedge the controller forever',
      );

      controller.fetch();
      await settle();
      expect(calls, 3);
    });

    test('reports a throwing listener through FlutterError', () async {
      controller.addFetchListener(() => throw StateError('network down'));

      controller.fetch();
      await settle();

      expect(reportedErrors, hasLength(1));
      expect(reportedErrors.single.exception, isStateError);
      expect(reportedErrors.single.library, 'flutter_gantt');
    });

    test('keeps running the remaining listeners after one throws', () async {
      final calls = <String>[];
      controller.addFetchListener(() {
        calls.add('first');
        throw StateError('network down');
      });
      controller.addFetchListener(() async {
        calls.add('second');
        throw StateError('also down');
      });
      controller.addFetchListener(() => calls.add('third'));

      controller.fetch();
      await settle();

      expect(calls, <String>['first', 'second', 'third']);
      expect(reportedErrors, hasLength(2));
    });

    test('still coalesces when the in-flight run fails', () async {
      final gates = <Completer<void>>[];
      var runs = 0;
      controller.addFetchListener(() {
        runs++;
        final gate = Completer<void>();
        gates.add(gate);
        return gate.future;
      });

      controller.fetch();
      await settle();
      controller.fetch();
      controller.fetch();

      gates[0].completeError(StateError('network down'));
      await settle();

      expect(runs, 2);
      expect(reportedErrors, hasLength(1));
      gates[1].complete();
      await settle();
    });

    test('date navigation triggers a fetch unless opted out', () async {
      var runs = 0;
      controller.addFetchListener(() => runs++);

      controller.next();
      await settle();
      expect(runs, 1);

      controller.prev();
      await settle();
      expect(runs, 2);

      controller.next(fetchData: false);
      await settle();
      expect(runs, 2);
    });

    test('removed listeners are no longer invoked', () async {
      var runs = 0;
      FutureOr<void> listener() => runs++;
      controller.addFetchListener(listener);

      controller.fetch();
      await settle();
      expect(runs, 1);

      controller.removeFetchListener(listener);
      controller.fetch();
      await settle();
      expect(runs, 1);
    });
  });
}
