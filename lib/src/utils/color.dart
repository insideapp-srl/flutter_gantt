import 'package:flutter/material.dart';

import '../classes/activity.dart';
import '../classes/theme.dart';

/// Extension methods for [Color] used in the Gantt chart.
extension ColorEx on Color {
  /// White or black, whichever has the higher contrast against this color.
  ///
  /// The better of the two reaches at least 4.58:1 on any color, above the
  /// 4.5:1 WCAG 1.4.3 asks for text. [ThemeData.estimateBrightnessForColor] is
  /// not used: it favors white and leaves it below 4.5:1 on mid tones.
  Color get onColor =>
      contrastWith(Colors.white) >= contrastWith(Colors.black)
          ? Colors.white
          : Colors.black;

  /// WCAG contrast ratio between this color and [other], from 1 to 21.
  double contrastWith(Color other) {
    final la = computeLuminance();
    final lb = other.computeLuminance();
    return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
  }
}

/// The colors the default cell and its edges draw for a [GanttActivity].
extension GanttActivityColors on GanttActivity {
  /// The cell color, falling back to the theme default.
  Color cellColor(GanttTheme theme) => color ?? theme.defaultCellColor;

  /// White or black against the cell, for the title text.
  ///
  /// The cell color is first blended over the theme background, since a
  /// translucent cell looks darker on a dark background. The hover is left
  /// out, so the color does not flip while the pointer is over the cell.
  Color onCellColor(GanttTheme theme) =>
      Color.alphaBlend(cellColor(theme), theme.backgroundColor).onColor;

  /// The progress line color: [GanttActivity.progressColor], or the same as
  /// the title text so the line and the title read as one.
  Color progressLineColor(GanttTheme theme) =>
      progressColor ?? onCellColor(theme);

  /// The progress line color at 30%, for the track under the line and the
  /// resize edges.
  Color trackColor(GanttTheme theme) {
    final line = progressLineColor(theme);
    return line.withValues(alpha: line.a * 0.3);
  }
}
