import 'dart:math';

class BenchmarkSampleStatistics {
  BenchmarkSampleStatistics.fromSamples(Iterable<int> samples)
    : samples = List<int>.unmodifiable(samples) {
    if (this.samples.isEmpty) {
      throw ArgumentError.value(samples, 'samples', 'Must not be empty.');
    }

    sortedSamples = List<int>.from(this.samples)..sort();
    meanMicros =
        this.samples.reduce((sum, value) => sum + value) / this.samples.length;
    medianMicros = _percentile(sortedSamples, 0.5);
    p95Micros = _percentile(sortedSamples, 0.95);
    minMicros = sortedSamples.first;
    maxMicros = sortedSamples.last;

    final standardDeviation = _computeStandardDeviation(
      samples: this.samples,
      mean: meanMicros,
    );
    coefficientOfVariation = meanMicros == 0
        ? 0.0
        : standardDeviation / meanMicros;
  }

  final List<int> samples;
  late final List<int> sortedSamples;
  late final int medianMicros;
  late final int p95Micros;
  late final int minMicros;
  late final int maxMicros;
  late final double meanMicros;
  late final double coefficientOfVariation;
}

int _percentile(List<int> sortedSamples, double percentile) {
  if (sortedSamples.length == 1) {
    return sortedSamples.single;
  }

  final rawIndex = ((sortedSamples.length - 1) * percentile).round();
  final boundedIndex = rawIndex.clamp(0, sortedSamples.length - 1);
  return sortedSamples[boundedIndex];
}

double _computeStandardDeviation({
  required List<int> samples,
  required double mean,
}) {
  final variance =
      samples
          .map((value) => pow(value - mean, 2))
          .reduce((sum, value) => sum + value) /
      samples.length;
  return sqrt(variance);
}
