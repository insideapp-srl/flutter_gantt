import 'dart:ui';

import '../utils/datetime.dart';

class GantActivity {
  late DateTime start;
  late DateTime end;
  final String title;
  final String description;
  final List<GantActivitySegment>? segments;
  final List<GantActivity>? children;
  final Function(GantActivity activity)? onTap;
  final Color? color;

  GantActivity({
    required DateTime start,
    required DateTime end,
    required this.title,
    required this.description,
    this.segments,
    this.children,
    this.onTap,
    this.color,
  }) : assert(start.toDate.isBeforeOrSame(end.toDate)) {
    this.start = start.toDate;
    this.end = end.toDate;
    if (segments != null) {
      for (final segment in segments!) {
        assert(
          segment.start.isDateBetween(start, end) &&
              segment.end.isDateBetween(start, end),
        );
      }
    }
  }

  int get daysDuration => end.difference(start).inDays + 1;
}

class GantActivitySegment {
  late DateTime start;
  late DateTime end;
  final String title;
  final String description;
  final Function(GantActivity activity)? onTap;
  final Color? color;

  GantActivitySegment({
    required DateTime start,
    required DateTime end,
    required this.title,
    required this.description,
    this.onTap,
    this.color,
  }) : assert(start.toDate.isBeforeOrSame(end.toDate)) {
    this.start = start.toDate;
    this.end = end.toDate;
  }
}
