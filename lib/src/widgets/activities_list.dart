import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../flutter_gantt.dart';

/// Displays the list of activity names on the left side of the Gantt chart.
///
/// This widget shows activity titles, optional icons, and action buttons in a
/// scrollable list that synchronizes with the [ActivitiesGrid].
class ActivitiesList extends StatelessWidget {
  /// The list of [GanttActivity] items to display.
  ///
  /// Can contain hierarchical activities with parent-child relationships.
  final List<GanttActivity> activities;

  /// Optional [ScrollController] to synchronize scrolling with the grid view.
  final ScrollController? controller;

  /// Creates an [ActivitiesList] widget.
  ///
  /// [activities] must not be null and should contain at least one activity.
  /// [showIsoWeek] enables the ISO week-number row (default: `false`).
  const ActivitiesList({
    super.key,
    required this.activities,
    this.controller,
    this.showIsoWeek = false,
    this.collapseActionsBelowWidth,
  });

  /// Whether to show the ISO week number row.
  ///
  /// If `true`, a row displaying ISO-8601 week numbers is shown
  /// between the month headers and the day cells.
  final bool showIsoWeek;

  /// See [Gantt.collapseActionsBelowWidth].
  final double? collapseActionsBelowWidth;

  /// Sizes a row action to a `cellHeight` square.
  ///
  /// The default size of [IconButton] (40px, 48px with the touch target of
  /// mobile platforms) left almost no room for the title on narrow layouts.
  /// The density is fixed so the size does not shrink on desktop. Any value
  /// set in [GanttActivityAction.style] wins over these.
  static ButtonStyle _compactActionStyle(GanttTheme theme) =>
      IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.square(theme.cellHeight),
        maximumSize: Size.square(theme.cellHeight),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
      );

  /// Recursively builds widgets for activities and their children.
  ///
  /// [activities] - The list of activities to build widgets for
  /// [theme] - The current [GanttTheme] for styling
  /// [nested] - The current nesting level (used for indentation)
  /// [collapseActions] - Whether rows with more than one action show them in a
  /// menu
  List<Widget> getItems(
    List<GanttActivity> activities,
    GanttTheme theme, {
    int nested = 0,
    bool collapseActions = false,
  }) => List.generate(
    activities.length,
    (index) => Padding(
      padding: EdgeInsets.only(
        top: theme.rowPadding + (nested == 0 ? theme.rowsGroupPadding : 0),
        left:
            theme.listIndent == null
                ? 8.0 * (nested + 1)
                : (nested == 0 ? 8.0 : theme.listIndent!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: theme.cellHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (activities[index].iconTitle != null)
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: activities[index].iconTitle!,
                  ),
                Expanded(
                  child:
                      activities[index].listTitleWidget ??
                      activities[index].titleWidget ??
                      Tooltip(
                        message: activities[index].tooltip ?? '',
                        child: Text(
                          activities[index].listTitle ??
                              activities[index].title!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                ),
                if (activities[index].actions?.isNotEmpty == true)
                  collapseActions && activities[index].actions!.length > 1
                      ? _actionsMenu(activities[index].actions!, theme)
                      : Row(
                        children:
                            activities[index].actions!
                                .map((e) => _actionButton(e, theme))
                                .toList(),
                      ),
              ],
            ),
          ),
          if (activities[index].children?.isNotEmpty == true)
            ...getItems(
              activities[index].children!,
              theme,
              nested: nested + 1,
              collapseActions: collapseActions,
            ),
        ],
      ),
    ),
  );

  /// A compact icon button for [action], with its tooltip if any.
  Widget _actionButton(GanttActivityAction action, GanttTheme theme) {
    final compact = _compactActionStyle(theme);
    final child = IconButton(
      onPressed: action.onTap,
      icon: Icon(action.icon, size: theme.cellHeight * 0.8),
      style: action.style?.merge(compact) ?? compact,
    );
    return action.tooltip != null
        ? Tooltip(message: action.tooltip, child: child)
        : child;
  }

  /// A single "more" button that opens [actions] in a menu, each with its icon
  /// and its tooltip as the label.
  ///
  /// A [MenuAnchor] around a compact button rather than a [PopupMenuButton],
  /// which is a full size [IconButton] and would not fit the row. The items
  /// keep the default menu colors: [GanttActivityAction.style] is meant for
  /// the icon button and is not applied to them.
  Widget _actionsMenu(List<GanttActivityAction> actions, GanttTheme theme) {
    // Without a tooltip the item would show its icon next to an empty label.
    assert(
      actions.every((e) => e.tooltip?.isNotEmpty == true),
      'Actions grouped in the "more" menu need a tooltip, used as the label '
      'of their item (see Gantt.collapseActionsBelowWidth).',
    );
    return MenuAnchor(
      builder:
          (context, menu, _) => Tooltip(
            message: MaterialLocalizations.of(context).moreButtonTooltip,
            child: IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: Icon(Icons.more_vert, size: theme.cellHeight * 0.8),
              style: _compactActionStyle(theme),
            ),
          ),
      menuChildren:
          actions
              .map(
                (e) => MenuItemButton(
                  onPressed: e.onTap,
                  leadingIcon: Icon(e.icon),
                  child: Text(e.tooltip ?? ''),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget build(BuildContext context) => Consumer<GanttTheme>(
    builder:
        (context, theme, child) => Padding(
          padding: EdgeInsets.only(
            top: theme.headerHeight + (showIsoWeek ? 10 : 0),
          ),
          child: LayoutBuilder(
            builder:
                (context, constraints) => ListView(
                  controller: controller,
                  children: getItems(
                    activities,
                    theme,
                    collapseActions:
                        collapseActionsBelowWidth != null &&
                        constraints.maxWidth < collapseActionsBelowWidth!,
                  ),
                ),
          ),
        ),
  );
}
