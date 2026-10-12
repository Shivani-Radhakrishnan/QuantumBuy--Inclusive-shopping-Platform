import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/services/colour_analysis.dart';

/// A [width]x[height] RGBA image whose left [redColumns] columns are red and
/// the rest white.
Uint8List halfAndHalf(int width, int height, int redColumns) {
  final data = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final i = (y * width + x) * 4;
      final red = x < redColumns;
      data[i] = 255;
      data[i + 1] = red ? 0 : 255;
      data[i + 2] = red ? 0 : 255;
      data[i + 3] = 255;
    }
  }
  return data;
}

void main() {
  test('names common colours', () {
    expect(colourName(const Color(0xFFFF0000)), 'red');
    expect(colourName(const Color(0xFF00AA00)), 'green');
    expect(colourName(const Color(0xFF0000FF)), 'blue');
    expect(colourName(const Color(0xFFFFFFFF)), 'white');
    expect(colourName(const Color(0xFF000000)), 'black');
    expect(colourName(const Color(0xFF808080)), 'grey');
    expect(colourName(const Color(0xFF8B4513)), 'brown');
    expect(colourName(const Color(0xFFFFFF00)), 'yellow');
    expect(colourName(const Color(0xFF800000)), 'dark red');
  });

  test('finds the main colours, their share and where they are', () {
    final colours = dominantColours(halfAndHalf(40, 40, 30), 40, 40, step: 1);
    expect(colours.map((c) => c.name), ['red', 'white']);
    expect(colours.first.share, closeTo(0.75, 0.01));
    expect(colours.first.position.dx, lessThan(0.5), reason: 'red is on the left');
    expect(colours.last.position.dx, greaterThan(0.7), reason: 'white is on the right');
  });

  test('ignores transparent pixels and empty images', () {
    expect(dominantColours(Uint8List(16), 2, 2), isEmpty);
    expect(dominantColours(Uint8List(0), 0, 0), isEmpty);
  });

  test('limits the number of colours', () {
    final colours = dominantColours(halfAndHalf(10, 10, 5), 10, 10, step: 1, count: 1);
    expect(colours, hasLength(1));
  });
}
