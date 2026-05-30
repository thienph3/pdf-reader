import 'package:flutter/material.dart';

/// App-wide spacing scale.
abstract class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// App-wide elevation levels.
abstract class Elevations {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 2;
  static const double high = 4;
}

/// Theme-aware highlight colors that work in both light and dark mode.
List<int> highlightColors(Brightness brightness) {
  if (brightness == Brightness.dark) {
    return const [
      0x60FFEB3B, // yellow
      0x6066BB6A, // green
      0x6042A5F5, // blue
      0x60EF5350, // red
      0x60AB47BC, // purple
      0x60FF7043, // orange
    ];
  }
  return const [
    0x80FFEB3B,
    0x8066BB6A,
    0x8042A5F5,
    0x80EF5350,
    0x80AB47BC,
    0x80FF7043,
  ];
}
