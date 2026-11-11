import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('should keep adapters and render off the legacy pipeline', () {
    final offenders = <String>[];
    for (final dir in ['lib/src/adapters', 'lib/src/render']) {
      for (final file in Directory(dir).listSync(recursive: true)) {
        if (file is! File || !file.path.endsWith('.dart')) continue;
        for (final line in file.readAsLinesSync()) {
          if (!line.startsWith('import ')) continue;
          if (line.contains('src/core/') ||
              line.contains('src/converter/') ||
              line.contains('package:tagflow/legacy.dart')) {
            offenders.add('${file.path}: $line');
          }
        }
      }
    }

    expect(offenders, isEmpty);
  });
}
