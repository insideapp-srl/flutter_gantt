# Flutter Gantt Chart

[![Pub Version](https://img.shields.io/pub/v/flutter_gantt)](https://pub.dev/packages/flutter_gantt) [![Pub Points](https://img.shields.io/pub/points/flutter_gantt)](https://pub.dev/packages/flutter_gantt/score) [![License](https://img.shields.io/github/license/insideapp-srl/flutter_gantt)](https://github.com/insideapp-srl/flutter_gantt/blob/main/LICENSE)

A production-ready, fully customizable Gantt chart widget for Flutter applications.

![Gantt Chart Demo](https://raw.githubusercontent.com/insideapp-srl/flutter_gantt/main/doc/static/img/preview.gif)

---

## Features

- 💓 Scrollable timeline view
- ↔  Draggable
- 🎈 Complete visual customization
- 🛳  Hierarchical activities with parent/child relationships
- 🙳  Activity segments with custom styling
- 👅 Built-in date utilities and calculations
- 🚀 Optimized for performance
- 😱 Responsive across all platforms

---

## Installation

Add to your `pubspec.yaml`:

`yaml
dependencies:
  flutter_gantt: <latest-version>
`

Then run:

`bash
flutter pub get
`

---

## Quick Start

```dart
import 'package:flutter_gantt/flutter_gantt.dart';

Gantt(
  theme: GanttTheme.of(context),
  activitiesAsync: (startDate, endDate, activity) async => _activities,
  holidaysAsync: (startDate, endDate, holidays) async _holidays,
  onActivityChanged: (activity, start, end) {
    if (start != null && end != null) {
      debugPrint('$activity was moved (Event on widget)');
    } else if (start != null) {
      debugPrint(
        '$activity start was moved (Event on widget)',
      );
    } else if (end != null) {
      debugPrint('$activity end was moved (Event on widget)');
    }
  },
),
```

---

## Documentation

### Core Components

#### `Gantt` Widget

The main chart container with these key properties:

| Property     | Type                   | Description                |
|--------------|------------------------|----------------------------|
| `startDate`  | DateTime               | Initial visible date       |
| `activities` | List<GanttActivity>    | Activities to display      |
| `holidays`   | List<GanttDateHoliday> | Special dates to highlight |
| `theme`      | GanttTheme             | Visual customization       |
| `controller` | GanttController        | Programmatic control       |

#### `GanttActivity`

Represents a task with:

```dart
GanttActivity(
  start: DateTime.now(),
  end: DateTime.now().add(Duration(days: 5)),
  title: 'Task Name',
  color: Colors.blue,
  // Optional:
  children: [/* sub-tasks */],
  segments: [/* phases */],
  onCellTap: (activity) => print('Tapped ${activity.title}'),
)
```

---

### Advanced Features

[**Programmatic Control:**]

```dart
final controller = GanttController(
    startDate: DateTime.now(),
    daysViews: 30,
);

// Navigate timeline
controller.next(days: 7);   // Move forward
controller.prev(days: 14);  // Move backward

// Update data
controller.setActivities(newActivities);
```

[**Custom Builders:**]

```dart
GanttActivity(
  cellBuilder: (date) => YourCustomWidget(date),
  titleWidget: YourTitleWidget(),
)
```

---

## Examples

[Explore complete examples](https://github.com/insideapp-srl/flutter_gantt/tree/main/example) in the example folder.

---

## Contributing

We welcome contributions!

---

## License

MIT – See [LICENSE](LICENSE) for details.

## Roadmap

- Added limitations when dragging
- Improving documentation
- Implementing cell segments
- Improving mobile usability