import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// One of the main colours in an image.
class DominantColour {
  const DominantColour({required this.color, required this.share, required this.position});

  /// Average colour of the pixels in this group.
  final Color color;

  /// Fraction of the sampled pixels (0-1) that fall in this group.
  final double share;

  /// Where the colour sits in the image, as fractions of width and height.
  final Offset position;

  String get name => colourName(color);
}

/// Finds the [count] main colours in raw RGBA pixel data.
///
/// Pixels are grouped by colour name ("red", "dark blue", "white"...), so
/// the result is what a shopper would call the colours rather than hundreds
/// of near-identical RGB values. Transparent pixels are ignored.
List<DominantColour> dominantColours(
  Uint8List rgba,
  int width,
  int height, {
  int count = 3,
  int step = 4,
}) {
  final groups = <String, _Group>{};
  var sampled = 0;
  for (var y = 0; y < height; y += step) {
    for (var x = 0; x < width; x += step) {
      final i = (y * width + x) * 4;
      if (i + 3 >= rgba.length) continue;
      if (rgba[i + 3] < 128) continue;
      final color = Color.fromARGB(255, rgba[i], rgba[i + 1], rgba[i + 2]);
      final group = groups.putIfAbsent(colourName(color), _Group.new);
      group.add(rgba[i], rgba[i + 1], rgba[i + 2], x / width, y / height);
      sampled++;
    }
  }
  if (sampled == 0) return const [];

  final sorted = groups.values.toList()..sort((a, b) => b.n.compareTo(a.n));
  return [
    for (final g in sorted.take(count))
      DominantColour(
        color: Color.fromARGB(255, g.r ~/ g.n, g.g ~/ g.n, g.b ~/ g.n),
        share: g.n / sampled,
        position: Offset(g.x / g.n, g.y / g.n),
      ),
  ];
}

class _Group {
  int n = 0, r = 0, g = 0, b = 0;
  double x = 0, y = 0;
  void add(int red, int green, int blue, double px, double py) {
    n++;
    r += red;
    g += green;
    b += blue;
    x += px;
    y += py;
  }
}

/// A plain-English name for [color], e.g. "red", "light blue", "grey".
String colourName(Color color) {
  final hsl = HSLColor.fromColor(color);
  final l = hsl.lightness;
  final s = hsl.saturation;
  final h = hsl.hue;

  if (l > 0.92) return 'white';
  if (l < 0.12) return 'black';
  if (s < 0.15) {
    if (l > 0.7) return 'light grey';
    if (l < 0.35) return 'dark grey';
    return 'grey';
  }

  String hue;
  if (h < 15 || h >= 345) {
    hue = 'red';
  } else if (h < 45) {
    hue = (l < 0.45) ? 'brown' : 'orange';
  } else if (h < 70) {
    hue = 'yellow';
  } else if (h < 165) {
    hue = 'green';
  } else if (h < 195) {
    hue = 'cyan';
  } else if (h < 255) {
    hue = 'blue';
  } else if (h < 290) {
    hue = 'purple';
  } else {
    hue = 'pink';
  }
  if (hue == 'brown') return hue;
  if (l < 0.3) return 'dark $hue';
  if (l > 0.75) return 'light $hue';
  return hue;
}

/// Decodes [provider] and returns its main colours.
Future<List<DominantColour>> analyseImageColours(ImageProvider provider, {int count = 3}) {
  final completer = Completer<List<DominantColour>>();
  final stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo info, bool _) async {
      stream.removeListener(listener);
      try {
        final data = await info.image.toByteData(format: ui.ImageByteFormat.rawRgba);
        completer.complete(data == null
            ? const []
            : dominantColours(data.buffer.asUint8List(), info.image.width, info.image.height, count: count));
      } catch (e) {
        completer.completeError(e);
      }
    },
    onError: (Object error, StackTrace? stack) {
      stream.removeListener(listener);
      if (!completer.isCompleted) completer.completeError(error, stack);
    },
  );
  stream.addListener(listener);
  return completer.future;
}
