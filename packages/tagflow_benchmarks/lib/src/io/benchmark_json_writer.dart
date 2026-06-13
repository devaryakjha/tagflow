import 'dart:convert';
import 'dart:io';

/// Writes an indented JSON benchmark artifact to [outputPath].
void writeBenchmarkJson(Map<String, Object?> json, String outputPath) {
  final outputFile = File(outputPath);
  outputFile.parent.createSync(recursive: true);
  outputFile.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
}
