import 'dart:convert';
import 'dart:io';

import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main(List<String> args) {
  final options = _CliOptions.parse(args);

  if (options.showHelp) {
    stdout.writeln(_CliOptions.help);
    return;
  }

  final fixtures = options.fixtureIds
      ?.map(_fixtureById)
      .toList(growable: false);

  final suite = TagflowNativeTransportBenchmarkSuite(
    warmupIterations: options.warmupIterations,
    sampleCount: options.sampleCount,
  );
  final result = suite.run(fixtures: fixtures);
  final jsonOutput = const JsonEncoder.withIndent(
    '  ',
  ).convert(result.toJson());

  if (options.outputPath != null) {
    final outputFile = File(options.outputPath!);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync('$jsonOutput\n');
    stdout.writeln(
      'Wrote native transport benchmark results to ${outputFile.path}',
    );
  }

  stdout.writeln(jsonOutput);
}

NativeTransportBenchmarkFixture _fixtureById(String id) {
  for (final fixture in nativeTransportBenchmarkFixtures) {
    if (fixture.id == id) {
      return fixture;
    }
  }
  throw ArgumentError.value(id, 'id', 'Unknown native transport fixture id.');
}

class _CliOptions {
  const _CliOptions({
    required this.outputPath,
    required this.fixtureIds,
    required this.warmupIterations,
    required this.sampleCount,
    required this.showHelp,
  });

  factory _CliOptions.parse(List<String> args) {
    String? outputPath;
    final fixtureIds = <String>[];
    var warmupIterations = 5;
    var sampleCount = 10;
    var showHelp = false;

    for (final arg in args) {
      if (arg == '--help') {
        showHelp = true;
        continue;
      }
      if (arg.startsWith('--output=')) {
        outputPath = arg.substring('--output='.length);
        continue;
      }
      if (arg.startsWith('--fixture=')) {
        fixtureIds.add(arg.substring('--fixture='.length));
        continue;
      }
      if (arg.startsWith('--warmup=')) {
        warmupIterations = int.parse(arg.substring('--warmup='.length));
        continue;
      }
      if (arg.startsWith('--samples=')) {
        sampleCount = int.parse(arg.substring('--samples='.length));
        continue;
      }

      throw ArgumentError('Unknown argument: $arg');
    }

    return _CliOptions(
      outputPath: outputPath,
      fixtureIds: fixtureIds.isEmpty ? null : fixtureIds,
      warmupIterations: warmupIterations,
      sampleCount: sampleCount,
      showHelp: showHelp,
    );
  }

  static const String help = '''
Usage: run_native_transport_benchmarks.dart [options]

Options:
  --output=<path>       Write JSON results to a file.
  --fixture=<id>        Limit execution to a fixture id. Repeatable.
  --warmup=<count>      Warmup transport runs per fixture. Default: 5
  --samples=<count>     Timed samples per fixture. Default: 10
  --help                Show this help message.
''';

  final String? outputPath;
  final List<String>? fixtureIds;
  final int warmupIterations;
  final int sampleCount;
  final bool showHelp;
}
