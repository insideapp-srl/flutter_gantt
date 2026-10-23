import 'package:flutter/material.dart';
import 'package:flutter_gantt/src/utils/color.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorEx.onColor', () {
    test('is white on dark colors and black on light ones', () {
      expect(Colors.black.onColor, Colors.white);
      expect(const Color(0xFF0D47A1).onColor, Colors.white);
      expect(Colors.white.onColor, Colors.black);
      expect(Colors.yellow.onColor, Colors.black);
    });

    test('is black on mid tones where Material would pick white', () {
      // Material blue 500: estimateBrightnessForColor calls it dark, but white
      // only reaches about 3.1:1 on it, black about 6.7:1.
      const blue = Color(0xFF2196F3);
      expect(ThemeData.estimateBrightnessForColor(blue), Brightness.dark);
      expect(blue.onColor, Colors.black);
      expect(blue.contrastWith(Colors.black), greaterThan(4.5));
    });

    test('reaches at least 4.5:1 on any color', () {
      for (var r = 0; r <= 255; r += 15) {
        for (var g = 0; g <= 255; g += 15) {
          for (var b = 0; b <= 255; b += 15) {
            final color = Color.fromARGB(255, r, g, b);
            expect(
              color.contrastWith(color.onColor),
              greaterThanOrEqualTo(4.5),
              reason: '$color',
            );
          }
        }
      }
    });
  });

  group('ColorEx.contrastWith', () {
    test('is 21 for black and white, 1 for the same color, symmetric', () {
      expect(Colors.black.contrastWith(Colors.white), closeTo(21, 0.01));
      expect(Colors.red.contrastWith(Colors.red), 1);
      expect(
        Colors.red.contrastWith(Colors.blue),
        Colors.blue.contrastWith(Colors.red),
      );
    });
  });
}
