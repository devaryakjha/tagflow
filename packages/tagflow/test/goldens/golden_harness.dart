import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

/// Key of the boundary golden images are captured from.
const goldenBoundaryKey = ValueKey<String>('tagflow-golden-boundary');

/// Logical width every golden is rendered at.
const double goldenWidth = 400;

/// Registers the bundled golden fonts found in [fontsDir].
///
/// [fontsDir] is resolved against the package directory, which is the working
/// directory `flutter test` runs in.
Future<void> loadGoldenFonts(String fontsDir) async {
  final families = <String, List<String>>{
    'Roboto': [
      'Roboto-Regular.ttf',
      'Roboto-Italic.ttf',
      'Roboto-Medium.ttf',
      'Roboto-MediumItalic.ttf',
      'Roboto-Bold.ttf',
      'Roboto-BoldItalic.ttf',
    ],
    'monospace': ['JetBrainsMono-Regular.ttf', 'JetBrainsMono-Bold.ttf'],
  };

  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File('$fontsDir/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

/// Declares one golden test per theme brightness for [html].
///
/// Baselines are written to `goldens/<name>_light.png` and
/// `goldens/<name>_dark.png` next to the calling test file.
void tagflowGoldenTest(
  String name, {
  required String html,
  TagflowComponentRegistry? registry,
  TagflowViewOptions? viewOptions,
  Future<void> Function(WidgetTester tester)? interact,
}) {
  for (final brightness in Brightness.values) {
    testWidgets('$name renders in ${brightness.name} theme', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(goldenWidth, 2000);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        GoldenFrame(
          brightness: brightness,
          child: Tagflow.html(
            html: html,
            registry: registry,
            viewOptions: viewOptions,
          ),
        ),
      );
      await interact?.call(tester);
      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(goldenBoundaryKey),
        matchesGoldenFile('goldens/${name}_${brightness.name}.png'),
      );
    });
  }
}

/// Fixed-width, themed surface that golden images are captured from.
class GoldenFrame extends StatelessWidget {
  /// Creates a golden frame around [child].
  const GoldenFrame({required this.brightness, required this.child, super.key});

  /// Theme brightness to render with.
  final Brightness brightness;

  /// Content under test.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: brightness, fontFamily: 'Roboto'),
      home: Align(
        alignment: Alignment.topLeft,
        child: RepaintBoundary(
          key: goldenBoundaryKey,
          child: SizedBox(
            width: goldenWidth,
            child: Material(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
