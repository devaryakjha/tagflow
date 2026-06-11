import 'package:flutter/foundation.dart';

@immutable
class BenchmarkEnvironment {
  const BenchmarkEnvironment({
    required this.packageVersion,
    required this.dartVersion,
    required this.flutterVersion,
    required this.os,
  });

  factory BenchmarkEnvironment.fromJson(Map<String, Object?> json) {
    return BenchmarkEnvironment(
      packageVersion: json['packageVersion']! as String,
      dartVersion: json['dartVersion']! as String,
      flutterVersion: json['flutterVersion']! as String,
      os: json['os']! as String,
    );
  }

  final String packageVersion;
  final String dartVersion;
  final String flutterVersion;
  final String os;

  Map<String, Object?> toJson() => <String, Object?>{
    'packageVersion': packageVersion,
    'dartVersion': dartVersion,
    'flutterVersion': flutterVersion,
    'os': os,
  };

  @override
  bool operator ==(Object other) {
    return other is BenchmarkEnvironment &&
        other.packageVersion == packageVersion &&
        other.dartVersion == dartVersion &&
        other.flutterVersion == flutterVersion &&
        other.os == os;
  }

  @override
  int get hashCode =>
      Object.hash(packageVersion, dartVersion, flutterVersion, os);
}

@immutable
class ParserBenchmarkFixtureResult {
  const ParserBenchmarkFixtureResult({
    required this.fixtureId,
    required this.inputBytes,
    required this.nodeCount,
    required this.sampleMicros,
    required this.medianMicros,
    required this.p95Micros,
    required this.minMicros,
    required this.maxMicros,
    required this.meanMicros,
    required this.coefficientOfVariation,
    required this.parsesPerSecond,
    required this.nodesPerSecond,
  });

  factory ParserBenchmarkFixtureResult.fromJson(Map<String, Object?> json) {
    return ParserBenchmarkFixtureResult(
      fixtureId: json['fixtureId']! as String,
      inputBytes: json['inputBytes']! as int,
      nodeCount: json['nodeCount']! as int,
      sampleMicros: (json['sampleMicros']! as List<Object?>)
          .map((value) => value! as int)
          .toList(growable: false),
      medianMicros: json['medianMicros']! as int,
      p95Micros: json['p95Micros']! as int,
      minMicros: json['minMicros']! as int,
      maxMicros: json['maxMicros']! as int,
      meanMicros: (json['meanMicros']! as num).toDouble(),
      coefficientOfVariation: (json['coefficientOfVariation']! as num)
          .toDouble(),
      parsesPerSecond: (json['parsesPerSecond']! as num).toDouble(),
      nodesPerSecond: (json['nodesPerSecond']! as num).toDouble(),
    );
  }

  final String fixtureId;
  final int inputBytes;
  final int nodeCount;
  final List<int> sampleMicros;
  final int medianMicros;
  final int p95Micros;
  final int minMicros;
  final int maxMicros;
  final double meanMicros;
  final double coefficientOfVariation;
  final double parsesPerSecond;
  final double nodesPerSecond;

  Map<String, Object?> toJson() => <String, Object?>{
    'fixtureId': fixtureId,
    'inputBytes': inputBytes,
    'nodeCount': nodeCount,
    'sampleMicros': sampleMicros,
    'medianMicros': medianMicros,
    'p95Micros': p95Micros,
    'minMicros': minMicros,
    'maxMicros': maxMicros,
    'meanMicros': meanMicros,
    'coefficientOfVariation': coefficientOfVariation,
    'parsesPerSecond': parsesPerSecond,
    'nodesPerSecond': nodesPerSecond,
  };

  @override
  bool operator ==(Object other) {
    return other is ParserBenchmarkFixtureResult &&
        other.fixtureId == fixtureId &&
        other.inputBytes == inputBytes &&
        other.nodeCount == nodeCount &&
        listEquals(other.sampleMicros, sampleMicros) &&
        other.medianMicros == medianMicros &&
        other.p95Micros == p95Micros &&
        other.minMicros == minMicros &&
        other.maxMicros == maxMicros &&
        other.meanMicros == meanMicros &&
        other.coefficientOfVariation == coefficientOfVariation &&
        other.parsesPerSecond == parsesPerSecond &&
        other.nodesPerSecond == nodesPerSecond;
  }

  @override
  int get hashCode => Object.hash(
    fixtureId,
    inputBytes,
    nodeCount,
    Object.hashAll(sampleMicros),
    medianMicros,
    p95Micros,
    minMicros,
    maxMicros,
    meanMicros,
    coefficientOfVariation,
    parsesPerSecond,
    nodesPerSecond,
  );
}

@immutable
class ParserBenchmarkSuiteResult {
  const ParserBenchmarkSuiteResult({
    required this.suite,
    required this.generatedAt,
    required this.environment,
    required this.warmupIterations,
    required this.sampleCount,
    required this.fixtureResults,
  });

  factory ParserBenchmarkSuiteResult.fromJson(Map<String, Object?> json) {
    return ParserBenchmarkSuiteResult(
      suite: json['suite']! as String,
      generatedAt: DateTime.parse(json['generatedAt']! as String),
      environment: BenchmarkEnvironment.fromJson(
        json['environment']! as Map<String, Object?>,
      ),
      warmupIterations: json['warmupIterations']! as int,
      sampleCount: json['sampleCount']! as int,
      fixtureResults: (json['fixtureResults']! as List<Object?>)
          .map(
            (value) => ParserBenchmarkFixtureResult.fromJson(
              value! as Map<String, Object?>,
            ),
          )
          .toList(growable: false),
    );
  }

  final String suite;
  final DateTime generatedAt;
  final BenchmarkEnvironment environment;
  final int warmupIterations;
  final int sampleCount;
  final List<ParserBenchmarkFixtureResult> fixtureResults;

  Map<String, Object?> toJson() => <String, Object?>{
    'suite': suite,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'environment': environment.toJson(),
    'warmupIterations': warmupIterations,
    'sampleCount': sampleCount,
    'fixtureResults': fixtureResults.map((result) => result.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    return other is ParserBenchmarkSuiteResult &&
        other.suite == suite &&
        other.generatedAt == generatedAt &&
        other.environment == environment &&
        other.warmupIterations == warmupIterations &&
        other.sampleCount == sampleCount &&
        listEquals(other.fixtureResults, fixtureResults);
  }

  @override
  int get hashCode => Object.hash(
    suite,
    generatedAt,
    environment,
    warmupIterations,
    sampleCount,
    Object.hashAll(fixtureResults),
  );
}

@immutable
class RenderBenchmarkFixtureResult {
  const RenderBenchmarkFixtureResult({
    required this.fixtureId,
    required this.inputBytes,
    required this.nodeCount,
    required this.conversionBuildSampleMicros,
    required this.medianConversionBuildMicros,
    required this.p95ConversionBuildMicros,
    required this.minConversionBuildMicros,
    required this.maxConversionBuildMicros,
    required this.meanConversionBuildMicros,
    required this.coefficientOfVariation,
  });

  factory RenderBenchmarkFixtureResult.fromJson(Map<String, Object?> json) {
    return RenderBenchmarkFixtureResult(
      fixtureId: json['fixtureId']! as String,
      inputBytes: json['inputBytes']! as int,
      nodeCount: json['nodeCount']! as int,
      conversionBuildSampleMicros:
          (json['conversionBuildSampleMicros']! as List<Object?>)
              .map((value) => value! as int)
              .toList(growable: false),
      medianConversionBuildMicros: json['medianConversionBuildMicros']! as int,
      p95ConversionBuildMicros: json['p95ConversionBuildMicros']! as int,
      minConversionBuildMicros: json['minConversionBuildMicros']! as int,
      maxConversionBuildMicros: json['maxConversionBuildMicros']! as int,
      meanConversionBuildMicros: (json['meanConversionBuildMicros']! as num)
          .toDouble(),
      coefficientOfVariation: (json['coefficientOfVariation']! as num)
          .toDouble(),
    );
  }

  final String fixtureId;
  final int inputBytes;
  final int nodeCount;
  final List<int> conversionBuildSampleMicros;
  final int medianConversionBuildMicros;
  final int p95ConversionBuildMicros;
  final int minConversionBuildMicros;
  final int maxConversionBuildMicros;
  final double meanConversionBuildMicros;
  final double coefficientOfVariation;

  Map<String, Object?> toJson() => <String, Object?>{
    'fixtureId': fixtureId,
    'inputBytes': inputBytes,
    'nodeCount': nodeCount,
    'conversionBuildSampleMicros': conversionBuildSampleMicros,
    'medianConversionBuildMicros': medianConversionBuildMicros,
    'p95ConversionBuildMicros': p95ConversionBuildMicros,
    'minConversionBuildMicros': minConversionBuildMicros,
    'maxConversionBuildMicros': maxConversionBuildMicros,
    'meanConversionBuildMicros': meanConversionBuildMicros,
    'coefficientOfVariation': coefficientOfVariation,
  };

  @override
  bool operator ==(Object other) {
    return other is RenderBenchmarkFixtureResult &&
        other.fixtureId == fixtureId &&
        other.inputBytes == inputBytes &&
        other.nodeCount == nodeCount &&
        listEquals(
          other.conversionBuildSampleMicros,
          conversionBuildSampleMicros,
        ) &&
        other.medianConversionBuildMicros == medianConversionBuildMicros &&
        other.p95ConversionBuildMicros == p95ConversionBuildMicros &&
        other.minConversionBuildMicros == minConversionBuildMicros &&
        other.maxConversionBuildMicros == maxConversionBuildMicros &&
        other.meanConversionBuildMicros == meanConversionBuildMicros &&
        other.coefficientOfVariation == coefficientOfVariation;
  }

  @override
  int get hashCode => Object.hash(
    fixtureId,
    inputBytes,
    nodeCount,
    Object.hashAll(conversionBuildSampleMicros),
    medianConversionBuildMicros,
    p95ConversionBuildMicros,
    minConversionBuildMicros,
    maxConversionBuildMicros,
    meanConversionBuildMicros,
    coefficientOfVariation,
  );
}

@immutable
class RenderBenchmarkSuiteResult {
  const RenderBenchmarkSuiteResult({
    required this.suite,
    required this.generatedAt,
    required this.environment,
    required this.warmupIterations,
    required this.sampleCount,
    required this.fixtureResults,
  });

  factory RenderBenchmarkSuiteResult.fromJson(Map<String, Object?> json) {
    return RenderBenchmarkSuiteResult(
      suite: json['suite']! as String,
      generatedAt: DateTime.parse(json['generatedAt']! as String),
      environment: BenchmarkEnvironment.fromJson(
        json['environment']! as Map<String, Object?>,
      ),
      warmupIterations: json['warmupIterations']! as int,
      sampleCount: json['sampleCount']! as int,
      fixtureResults: (json['fixtureResults']! as List<Object?>)
          .map(
            (value) => RenderBenchmarkFixtureResult.fromJson(
              value! as Map<String, Object?>,
            ),
          )
          .toList(growable: false),
    );
  }

  final String suite;
  final DateTime generatedAt;
  final BenchmarkEnvironment environment;
  final int warmupIterations;
  final int sampleCount;
  final List<RenderBenchmarkFixtureResult> fixtureResults;

  Map<String, Object?> toJson() => <String, Object?>{
    'suite': suite,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'environment': environment.toJson(),
    'warmupIterations': warmupIterations,
    'sampleCount': sampleCount,
    'fixtureResults': fixtureResults.map((result) => result.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    return other is RenderBenchmarkSuiteResult &&
        other.suite == suite &&
        other.generatedAt == generatedAt &&
        other.environment == environment &&
        other.warmupIterations == warmupIterations &&
        other.sampleCount == sampleCount &&
        listEquals(other.fixtureResults, fixtureResults);
  }

  @override
  int get hashCode => Object.hash(
    suite,
    generatedAt,
    environment,
    warmupIterations,
    sampleCount,
    Object.hashAll(fixtureResults),
  );
}

@immutable
class NativeTransportBenchmarkPhaseResult {
  const NativeTransportBenchmarkPhaseResult({
    required this.phaseId,
    required this.sampleMicros,
    required this.medianMicros,
    required this.p95Micros,
    required this.minMicros,
    required this.maxMicros,
    required this.meanMicros,
    required this.coefficientOfVariation,
  });

  factory NativeTransportBenchmarkPhaseResult.fromJson(
    Map<String, Object?> json,
  ) {
    return NativeTransportBenchmarkPhaseResult(
      phaseId: json['phaseId']! as String,
      sampleMicros: (json['sampleMicros']! as List<Object?>)
          .map((value) => value! as int)
          .toList(growable: false),
      medianMicros: json['medianMicros']! as int,
      p95Micros: json['p95Micros']! as int,
      minMicros: json['minMicros']! as int,
      maxMicros: json['maxMicros']! as int,
      meanMicros: (json['meanMicros']! as num).toDouble(),
      coefficientOfVariation: (json['coefficientOfVariation']! as num)
          .toDouble(),
    );
  }

  final String phaseId;
  final List<int> sampleMicros;
  final int medianMicros;
  final int p95Micros;
  final int minMicros;
  final int maxMicros;
  final double meanMicros;
  final double coefficientOfVariation;

  Map<String, Object?> toJson() => <String, Object?>{
    'phaseId': phaseId,
    'sampleMicros': sampleMicros,
    'medianMicros': medianMicros,
    'p95Micros': p95Micros,
    'minMicros': minMicros,
    'maxMicros': maxMicros,
    'meanMicros': meanMicros,
    'coefficientOfVariation': coefficientOfVariation,
  };

  @override
  bool operator ==(Object other) {
    return other is NativeTransportBenchmarkPhaseResult &&
        other.phaseId == phaseId &&
        listEquals(other.sampleMicros, sampleMicros) &&
        other.medianMicros == medianMicros &&
        other.p95Micros == p95Micros &&
        other.minMicros == minMicros &&
        other.maxMicros == maxMicros &&
        other.meanMicros == meanMicros &&
        other.coefficientOfVariation == coefficientOfVariation;
  }

  @override
  int get hashCode => Object.hash(
    phaseId,
    Object.hashAll(sampleMicros),
    medianMicros,
    p95Micros,
    minMicros,
    maxMicros,
    meanMicros,
    coefficientOfVariation,
  );
}

@immutable
class NativeTransportBenchmarkFixtureResult {
  const NativeTransportBenchmarkFixtureResult({
    required this.fixtureId,
    required this.documentBytes,
    required this.patchBytes,
    required this.nodeCount,
    required this.patchOperationCount,
    required this.phaseResults,
  });

  factory NativeTransportBenchmarkFixtureResult.fromJson(
    Map<String, Object?> json,
  ) {
    return NativeTransportBenchmarkFixtureResult(
      fixtureId: json['fixtureId']! as String,
      documentBytes: json['documentBytes']! as int,
      patchBytes: json['patchBytes']! as int,
      nodeCount: json['nodeCount']! as int,
      patchOperationCount: json['patchOperationCount']! as int,
      phaseResults: (json['phaseResults']! as List<Object?>)
          .map(
            (value) => NativeTransportBenchmarkPhaseResult.fromJson(
              value! as Map<String, Object?>,
            ),
          )
          .toList(growable: false),
    );
  }

  final String fixtureId;
  final int documentBytes;
  final int patchBytes;
  final int nodeCount;
  final int patchOperationCount;
  final List<NativeTransportBenchmarkPhaseResult> phaseResults;

  Map<String, Object?> toJson() => <String, Object?>{
    'fixtureId': fixtureId,
    'documentBytes': documentBytes,
    'patchBytes': patchBytes,
    'nodeCount': nodeCount,
    'patchOperationCount': patchOperationCount,
    'phaseResults': phaseResults.map((result) => result.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    return other is NativeTransportBenchmarkFixtureResult &&
        other.fixtureId == fixtureId &&
        other.documentBytes == documentBytes &&
        other.patchBytes == patchBytes &&
        other.nodeCount == nodeCount &&
        other.patchOperationCount == patchOperationCount &&
        listEquals(other.phaseResults, phaseResults);
  }

  @override
  int get hashCode => Object.hash(
    fixtureId,
    documentBytes,
    patchBytes,
    nodeCount,
    patchOperationCount,
    Object.hashAll(phaseResults),
  );
}

@immutable
class NativeTransportBenchmarkSuiteResult {
  const NativeTransportBenchmarkSuiteResult({
    required this.suite,
    required this.generatedAt,
    required this.environment,
    required this.warmupIterations,
    required this.sampleCount,
    required this.fixtureResults,
  });

  factory NativeTransportBenchmarkSuiteResult.fromJson(
    Map<String, Object?> json,
  ) {
    return NativeTransportBenchmarkSuiteResult(
      suite: json['suite']! as String,
      generatedAt: DateTime.parse(json['generatedAt']! as String),
      environment: BenchmarkEnvironment.fromJson(
        json['environment']! as Map<String, Object?>,
      ),
      warmupIterations: json['warmupIterations']! as int,
      sampleCount: json['sampleCount']! as int,
      fixtureResults: (json['fixtureResults']! as List<Object?>)
          .map(
            (value) => NativeTransportBenchmarkFixtureResult.fromJson(
              value! as Map<String, Object?>,
            ),
          )
          .toList(growable: false),
    );
  }

  final String suite;
  final DateTime generatedAt;
  final BenchmarkEnvironment environment;
  final int warmupIterations;
  final int sampleCount;
  final List<NativeTransportBenchmarkFixtureResult> fixtureResults;

  Map<String, Object?> toJson() => <String, Object?>{
    'suite': suite,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'environment': environment.toJson(),
    'warmupIterations': warmupIterations,
    'sampleCount': sampleCount,
    'fixtureResults': fixtureResults.map((result) => result.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    return other is NativeTransportBenchmarkSuiteResult &&
        other.suite == suite &&
        other.generatedAt == generatedAt &&
        other.environment == environment &&
        other.warmupIterations == warmupIterations &&
        other.sampleCount == sampleCount &&
        listEquals(other.fixtureResults, fixtureResults);
  }

  @override
  int get hashCode => Object.hash(
    suite,
    generatedAt,
    environment,
    warmupIterations,
    sampleCount,
    Object.hashAll(fixtureResults),
  );
}
