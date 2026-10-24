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
- 🙳  Activity custom builder
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

| Property      | Type                   | Description                     |
|---------------|------------------------|---------------------------------|
| `startDate`   | DateTime               | Initial visible date            |
| `activities`  | List<GanttActivity>    | Activities to display           |
| `holidays`    | List<GanttDateHoliday> | Special dates to highlight      |
| `theme`       | GanttTheme             | Visual customization            |
| `controller`  | GanttController        | Programmatic control            |
| `showIsoWeek` | bool                   | Enables the ISO week-number row |
| `activitiesListHeader` | Widget | Widget shown in the empty area above the activities list |
| `activitiesListWidth` | GanttActivitiesListWidth | Makes the activities list column resizable |

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
  onCellTap: (activity) => print('Tapped ${activity.title}'),
)
```

---

### Advanced Features

#### Programmatic Control

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

#### Custom Builders

```dart
GanttActivity(
  cellBuilder: (date) => YourCustomWidget(date),
  titleWidget: YourTitleWidget(),
)
```

#### ISO Weeks

```dart
GanttActivity(
  showIsoWeek: true,
  ...
)
```

![Weeks](https://raw.githubusercontent.com/insideapp-srl/flutter_gantt/main/doc/static/img/show_weeks.png)

#### Activities List Header

Fill the empty area at the top of the activities list column, aligned with the calendar header:

```dart
Gantt(
  activitiesListHeader: Center(child: Text('Activities')),
  ...
)
```

#### Resizable Activities List

Pass a `GanttActivitiesListWidth` to let users resize the activities list column by dragging its edge. The width is expressed in logical pixels and is not persisted by the package: restore it through `width` and save it from `onChanged`, which is called when the drag ends.

```dart
Gantt(
  activitiesListWidth: GanttActivitiesListWidth(
    width: prefs.getDouble('ganttListWidth'), // null = derived from the flex ratio
    minWidth: 150,
    maxWidth: 500,
    onChanged: (width) => prefs.setDouble('ganttListWidth', width),
  ),
  ...
)
```

When `activitiesListWidth` is `null`, the column is not resizable and its width is driven by `activitiesListFlex` and `gridAreaFlex`.

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
- Improving mobile usability