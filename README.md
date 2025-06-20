# Flutter Gantt Chart

[![Pub Version](https://img.shields.io/pub/v/flutter_gantt)](https://pub.dev/packages/flutter_gantt)  
[![Pub Points](https://img.shields.io/pub/points/flutter_gantt)](https://pub.dev/packages/flutter_gantt/score)  
[![License](https://img.shields.io/github/license/insideapp-srl/flutter_gantt)](https://github.com/insideapp-srl/flutter_gantt/blob/main/LICENSE)

A production-ready, fully customizable Gantt chart widget for Flutter applications.

![Gantt Chart Demo](https://raw.githubusercontent.com/insideapp-srl/flutter_gantt/main/assets/demo.gif)

---

## Features

- 🗓 Interactive timeline navigation (scroll/pan/zoom)  
- 🎨 Complete visual customization  
- 🌳 Hierarchical activities with parent/child relationships  
- 🏷 Activity segments with custom styling  
- 📅 Built-in date utilities and calculations  
- 🚀 Optimized for performance  
- 📱 Responsive across all platforms  

---

## Installation

Aggiungi al tuo `pubspec.yaml`:

```yaml
dependencies:
  flutter_gantt: ^1.0.0
```

Poi esegui:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:flutter_gantt/flutter_gantt.dart';

Gantt(
  startDate: DateTime(2023, 1, 1),
  activities: [
    GantActivity(
      start: DateTime(2023, 1, 1),
      end: DateTime(2023, 1, 10),
      title: 'Project Phase 1',
      color: Colors.blue,
      children: [
        GantActivity(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 5),
          title: 'Development',
          segments: [
            GantActivitySegment(
              start: DateTime(2023, 1, 3),
              end: DateTime(2023, 1, 4),
              title: 'Review',
              color: Colors.orange,
            ),
          ],
        ),
      ],
    ),
  ],
  holidays: [
    GantDateHoliday(
      date: DateTime(2023, 1, 6),
      holiday: 'Team Offsite',
    ),
  ],
)
```

---

## Documentation

### Core Components

#### `Gantt` Widget

The main chart container with these key properties:

| Property       | Type                        | Description                 |
|----------------|-----------------------------|-----------------------------|
| `startDate`    | `DateTime`                  | Initial visible date        |
| `activities`   | `List<GantActivity>`        | Activities to display       |
| `holidays`     | `List<GantDateHoliday>`     | Special dates to highlight  |
| `theme`        | `GanttTheme`                | Visual customization        |
| `controller`   | `GanttController`           | Programmatic control        |

#### `GantActivity`

Represents a task with:

```dart
GantActivity(
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

**Programmatic Control:**

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

**Custom Builders:**

```dart
GantActivity(
  cellBuilder: (date) => YourCustomWidget(date),
  titleWidget: YourTitleWidget(),
)
```

---

## Examples

Explore complete examples in the [example folder](https://github.com/insideapp-srl/flutter_gantt/tree/main/example).

---

## Contributing

We welcome contributions! Please read our [contributing guidelines](CONTRIBUTING.md).

---

## License

MIT – See [LICENSE](LICENSE) for details.
