## [1.4.0] - 2026-10-24

@rickypid
Co-authored-by: a-nisi-insideapp <a-nisi-insideapp@users.noreply.github.com>

- Add `activitiesListHeader` to `Gantt` to fill the empty area at the top of the activities list column with a custom widget, aligned with the calendar header.
- Add `activitiesListWidth` to `Gantt` with the new `GanttActivitiesListWidth` class to make the activities list column resizable by dragging its edge. The width is expressed in logical pixels and is not persisted by the package: restore it through `width` and save it from `onChanged`, called when the drag ends. `minWidth`/`maxWidth` bound the column, which always leaves room for at least one day column in the grid. Without a stored `width` the column starts from its flex share, bounded by `minWidth`, so it also keeps the titles readable on narrow layouts. When not provided, the column keeps the fixed flex layout.
- Refetch data when resizing the activities list column changes the visible date range.
- The row actions of the activities list are now `cellHeight` squares (24px by default) instead of the default 40/48px `IconButton`, so the titles keep a usable width on narrow layouts (#32). Values set in `GanttActivityAction.style` still win over the compact size.
- Add `Gantt.collapseActionsBelowWidth`: below this width of the activities list, the rows with more than one action show them in a single "more" menu, each with its icon and its tooltip as the label, so those actions need a tooltip (asserted in debug mode). Defaults to `null` (always buttons).
- Add `GanttTheme.listIndent`: the indent each nesting level adds in the activities list. Defaults to `null`, which keeps the current indent growing with the depth (8, 24, 48...).
- Add `GanttActivity.progress` (0.0–1.0) and `GanttActivity.progressColor`: the default cell draws the progress as a line along its bottom edge, over a track that spans the activity, so it reads as a progress bar (the track alone at 0%). Track and line are inset 8px from the real start and end of the activity, in line with the title, and are measured on the whole activity: on a side cut by the visible range they continue beyond the grid edge instead of stopping at it. The default line color is the same as the title text, the track uses the line color at 30% opacity.
- The title of the default cell is now white or black, whichever has the higher contrast against the cell color (at least 4.5:1, WCAG 1.4.3), instead of the app text color, which could be unreadable on colored cells (e.g. white on yellow). Only text without a color of its own takes it.
- The resize edges of a cell use the track color instead of a fixed translucent white, so they show on light cells too, and show the left-right resize cursor (the start edge showed the right one). On a side cut by the visible range the edge is no longer drawn, since the real start or end is out of sight.
- Fix the chart not following a new `theme` (e.g. switching the app between light and dark): `Gantt` now applies the theme it is rebuilt with in `didUpdateWidget`.
- `GanttTheme` now has value equality (`==` and `hashCode`), so a theme rebuilt with the same values no longer counts as a change.
- Add `GanttController.setTheme(theme, {notify})`, like `setHolidays`, to set the theme without notifying the listeners while a build is in progress.
- Fix `GanttController.removeAllFetchListener()` (also called by `dispose()`) throwing a `ConcurrentModificationError` when a fetch listener was registered, e.g. when the controller was disposed while its `Gantt` was still mounted: it removed the listeners one by one while iterating over them.
- Apply `rowsGroupPadding` only between top-level groups, not above the first one, in both the activities list and the grid.
- **Breaking:** raise the minimum SDK to Dart `^3.8.0` / Flutter `>=3.32.0`, the versions actually required by the development dependencies (`flutter_lints` 6). Sources are reformatted with the Dart 3.8 formatter style.
- CI: replace the analyze workflow with a CI running format, analyze, tests and the pana score check on the minimum Flutter version and on stable; add automated publishing to pub.dev on version tags and Dependabot.

## [1.3.0] - 2026-09-22

@a-nisi-insideapp

- Fix a race between overlapping `fetch()` calls (e.g. the automatic fetch on mount racing a caller's own refetch triggered by async filter restoration): `GanttController` now serializes fetches instead of running them concurrently — at most one fetch is ever in flight, and any `fetch()` call that arrives while one is running is coalesced into a single follow-up run instead of starting a second one. This removes the need for callers to guard against stale responses overwriting fresher ones.
- A fetch listener that throws (a failing `activitiesAsync`/`holidaysAsync`, for instance) no longer leaves `GanttController` permanently unable to fetch, and no longer skips the remaining listeners. The failure is reported through `FlutterError.reportError` instead of being swallowed.
- Fix a `ConcurrentModificationError` when a fetch listener was added or removed while a fetch was in flight — for example a `Gantt` widget disposed while its data was still loading.
- Add an optional `style` to `GanttActivityAction`, applied to the action's `IconButton`, so callers can customize the button (e.g. its color on hover).

## [1.2.2] - 2026-04-28

@rickypid
Co-authored-by: RichiB20 <RichiB20@users.noreply.github.com>

- Fix `setState` called during build in `initState` by deferring `controller.fetch()` via `addPostFrameCallback`.
- Fix `setState` called on unmounted widget in `_getAsync` by adding `mounted` guards before each `setState` call.
- Skip `controller.fetch()` on pan end when the visible date range has not changed (e.g. simple tap or sub-day drag).

## [1.2.1] - 2026-03-31

@rickypid

- Update `getDayHoliday` to handle multiple holidays per date

## [1.2.0] - 2025-12-28

@rickypid
Co-authored-by: beeboy36 <beeboy36@users.noreply.github.com>
Co-authored-by: nezar-cube <nezar-cube@users.noreply.github.com>

- Update `getNamedMonths` to append the year for months spanning multiple years. (#23)
- Added customizable month-to-text conversion for Gantt by parameter function `monthToText` (#23)
- Increase header height to improve layout spacing.
- Added ellipsis for overflowing activity titles. (#22)
- Rename `Custom Builders` section to `ISO Weeks` in README for clarity.
- Remove `activity segments` and update README to reflect changes. Simplify activity structure.
- Set `GanttTheme` as non-nullable and update default initialization logic in `GanttController`.
- Added RTL (Right-to-Left) locale support for drag navigation and alignment @nezar-cube (#27)
- Fixed the drag direction inversion in RTL locales (Arabic, Hebrew, Farsi, Urdu) @nezar-cube (#27)
- Fixed activity row alignment for activities outside the visible date range in RTL locales @nezar-cube (#27)
- Improved internationalization support with proper text direction handling @nezar-cube (#27)

## [1.1.1] - 2025-11-18

@rickypid

- Added a notification dot to the top-right of the day cell when a holiday is present.

## [1.1.0] - 2025-11-17

@rickypid

- Support for displaying ISO-8601 week numbers in the calendar grid.
- New showIsoWeek parameter in both CalendarGrid and Gantt widgets to enable week-number rendering.
- ISO week calculation via isoWeekNumber extension on DateTime.
- weeks getter to group visible days by ISO week and compute flex distribution.
- Documentation for all newly introduced properties, methods, and extensions.

## [1.0.1] - 2025-11-16

@r1wtn

* Customizable flex ratios for activities list and grid area. (#18)
 
## [1.0.0] - 2025-08-25

@rickypid

* Add `daysViews` as a controller parameter, this allows you to establish a view with the desired days. (#11)

### Update dependencies

- provider: ^6.1.5+1
- flutter_lints: ^6.0.0

## [0.10.0] - 2025-07-18

@RichiB20

The version 0.9.3 brings the following breaking changes:

* BREAKING CHANGES - Rename `GantActivity` in `GanttActivity`
* BREAKING CHANGES - Rename `GantActivityAction` in `GanttActivityAction`
* BREAKING CHANGES - Rename `GantActivitySegment` in `GanttActivitySegment`
* BREAKING CHANGES - Rename `GantActivityOnChangedEvent` in `GanttActivityOnChangedEvent`

## [0.9.3] - 2025-07-17

@RichiB20

* Add parent and children limitation during dragging
* Add `limitStart` and `limitEnd` for activity
* Add `allowParentIndependentDateMovement` for gantt
* Fix typo Gant -> Gantt

## [0.9.2] - 2025-07-08

@rickypid
@RichiB20

* Draggable start/end activity
* Draggable activity
* Add documentations
* Add activity builder
* Add highlighted dates

## [0.0.6] - 2025-06-25

@RichiB20

* Add customization widget and text for activities list title and cell title.
* Add indication for current day.

## [0.0.5] - 2025-06-20

@RichiB20 @rickypid

* Add holidays.
 
## [0.0.4] - 2025-05-09

@RichiB20 @rickypid

* Init project.
 
## [0.0.3] - 2025-04-11

* Init project.
 
## [0.0.2] - 2025-04-03

@RichiB20

* Init project.

## [0.0.1] - 2025-03-17

@rickypid

* Init project.
