## [1.1.2] - 2025-12-13

@rickypid

- Update `getNamedMonths` to append the year for months spanning multiple years. (#23)
- Added customizable month-to-text conversion for Gantt by parameter function `monthToText` (#23)
- Increase header height to improve layout spacing.
- Added ellipsis for overflowing activity titles. (#22)

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
