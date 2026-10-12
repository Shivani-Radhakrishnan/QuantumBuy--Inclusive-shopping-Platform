// Renders the README screenshots and demo-GIF frames from the real app,
// using the Roboto and Material Icons fonts that ship with the Flutter SDK.
// Not part of the test suite. Run with:
//
//   flutter test tool/render_frames_test.dart
//
// PNGs (720x1480) are written to build/frames, or to $FRAMES_DIR if set.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_app/data/product_catalog.dart';

import '../test/widget/test_app.dart';

final fonts = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts/';
final out = Platform.environment['FRAMES_DIR'] ?? 'build/frames';

Future<void> loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('$fonts$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

var frame = 0;
Future<void> snap(WidgetTester tester, String name) async {
  // Let images decode and colour analysis finish.
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final widget = element.widget as Image;
        await precacheImage(widget.image, element);
      }
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
  }
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('root')).first);
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$out/${(frame++).toString().padLeft(2, '0')}_$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('demo frames', (tester) async {
    Directory(out).createSync(recursive: true);
    await tester.runAsync(() async {
      await loadFont('Roboto', ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']);
      await loadFont('MaterialIcons', ['MaterialIcons-Regular.otf']);
      // Text with no font family uses the test font; show it as Roboto too.
      await loadFont('Ahem', ['Roboto-Regular.ttf']);
    });
    tester.view.physicalSize = const Size(720, 1480);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await pumpApp(tester, wrap: (app) => RepaintBoundary(key: const Key('root'), child: app));
    await snap(tester, 'home');

    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();
    await snap(tester, 'categories');

    await tester.tap(find.text('Electronics'));
    await tester.pumpAndSettle();
    await snap(tester, 'electronics');
    await tester.tap(find.byTooltip('Add Laptop to cart'));
    await tester.pumpAndSettle();
    await snap(tester, 'added');

    await tester.tap(find.text('Laptop'));
    await tester.pumpAndSettle();
    await snap(tester, 'detail');

    navigatorOf(tester).pushNamed('/voiceOrder');
    await tester.pumpAndSettle();
    await snap(tester, 'voice');
    await tester.enterText(find.byKey(const Key('typedCommandField')), 'order two headphones');
    await tester.pump();
    await snap(tester, 'voice_typed');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await snap(tester, 'voice_done');

    navigatorOf(tester).pushNamed('/cart');
    await tester.pumpAndSettle();
    await snap(tester, 'cart');

    navigatorOf(tester).pushNamed('/settings');
    await tester.pumpAndSettle();
    await snap(tester, 'settings');
    final s = settingsOf(tester);
    await s.toggleHighContrast(true);
    await tester.pumpAndSettle();
    await snap(tester, 'settings_hc');
    await s.toggleVoiceControl(true);
    await s.toggleAltText(true);
    await s.toggleSimplifiedText(true);
    await tester.pumpAndSettle();
    await snap(tester, 'settings_all');

    navigatorOf(tester).pushNamedAndRemoveUntil('/home', (_) => false);
    await tester.pumpAndSettle();
    await snap(tester, 'home_hc');

    final tv = const ProductRepository().allProducts.firstWhere((p) => p.name == 'Smart TV');
    navigatorOf(tester).pushNamed('/productDetail', arguments: tv);
    await tester.pumpAndSettle();
    await snap(tester, 'detail_hc');
  });
}
