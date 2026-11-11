import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_benchmarks/src/render/render_benchmark_suite.dart';
import 'package:tagflow_benchmarks/src/results/benchmark_result.dart';
import 'package:tagflow_benchmarks/src/results/environment_detector.dart';
import 'package:tagflow_benchmarks/src/results/sample_statistics.dart';

/// Benchmarks for live documents: patches on a large document, the Markdown
/// stream, and rendering a stream as it grows.
///
/// Each lane reports per-operation timings, so a regression that makes one
/// patch or one chunk depend on the document length shows up as a growing
/// median.
class TagflowStreamingBenchmarkSuite {
  /// Creates a streaming benchmark suite.
  const TagflowStreamingBenchmarkSuite({
    this.patchDocumentSections = 1000,
    this.patchCount = 200,
    this.markdownRepeats = 4,
    this.chunkSize = 24,
    this.renderChunks = 120,
  });

  /// Sections in the patched document. Each section has 12 nodes.
  final int patchDocumentSections;

  /// Timed `replaceNode` patches.
  final int patchCount;

  /// Copies of the mixed Markdown fixture in the streamed text.
  final int markdownRepeats;

  /// Characters per streamed chunk.
  final int chunkSize;

  /// Timed chunks for the render lane.
  final int renderChunks;

  /// Runs the patch and Markdown stream lanes, and the render lane when
  /// [pumpWidget] is given.
  Future<StreamingBenchmarkSuiteResult> run({
    BenchmarkWidgetPump? pumpWidget,
  }) async {
    final markdown = List.filled(markdownRepeats, _mixedMarkdown).join('\n');
    return StreamingBenchmarkSuiteResult(
      generatedAt: DateTime.now().toUtc(),
      environment: detectBenchmarkEnvironment(),
      lanes: [
        _patchLane(),
        _markdownStreamLane(markdown),
        if (pumpWidget != null) await _renderLane(markdown, pumpWidget),
      ],
    );
  }

  StreamingBenchmarkLaneResult _patchLane() {
    var document = TagflowDocument(
      id: 'bench',
      children: [
        for (var i = 0; i < patchDocumentSections; i++) _section(i, 'v0'),
      ],
    );
    final nodeCount = _countNodes(document.children);
    final random = Random(7);
    final samples = <int>[];
    for (var i = 0; i < patchCount; i++) {
      final section = random.nextInt(patchDocumentSections);
      final patch = TagflowDocumentPatch.replaceNode(
        nodeId: 's$section.p',
        node: _paragraph(section, 'v${i + 1}'),
      );
      final stopwatch = Stopwatch()..start();
      document = document.applyPatch(patch);
      stopwatch.stop();
      samples.add(max(stopwatch.elapsedMicroseconds, 1));
    }
    return StreamingBenchmarkLaneResult(
      lane: 'patch.replaceNode',
      size: nodeCount,
      stats: BenchmarkSampleStatistics.fromSamples(samples),
    );
  }

  StreamingBenchmarkLaneResult _markdownStreamLane(String markdown) {
    final stream = TagflowMarkdownStream();
    final samples = <int>[];
    for (final chunk in _chunks(markdown)) {
      final stopwatch = Stopwatch()..start();
      stream.add(chunk);
      stopwatch.stop();
      samples.add(max(stopwatch.elapsedMicroseconds, 1));
    }
    stream
      ..close()
      ..dispose();
    return StreamingBenchmarkLaneResult(
      lane: 'markdown.stream.add',
      size: markdown.length,
      stats: BenchmarkSampleStatistics.fromSamples(samples),
    );
  }

  Future<StreamingBenchmarkLaneResult> _renderLane(
    String markdown,
    BenchmarkWidgetPump pumpWidget,
  ) async {
    final stream = TagflowMarkdownStream();
    final chunks = _chunks(markdown).toList();
    // Render the first half untimed, so the timed chunks land on a long
    // document with many finished blocks.
    final warm = max(0, chunks.length - renderChunks);
    for (final chunk in chunks.take(warm)) {
      stream.add(chunk);
    }
    final host = _StreamHost(stream: stream);
    await pumpWidget(host);
    final samples = <int>[];
    for (final chunk in chunks.skip(warm)) {
      stream.add(chunk);
      final stopwatch = Stopwatch()..start();
      await pumpWidget(host);
      stopwatch.stop();
      samples.add(max(stopwatch.elapsedMicroseconds, 1));
    }
    await pumpWidget(const SizedBox.shrink());
    stream.dispose();
    return StreamingBenchmarkLaneResult(
      lane: 'markdown.stream.render',
      size: markdown.length,
      stats: BenchmarkSampleStatistics.fromSamples(samples),
    );
  }

  Iterable<String> _chunks(String text) sync* {
    for (var i = 0; i < text.length; i += chunkSize) {
      yield text.substring(i, min(i + chunkSize, text.length));
    }
  }
}

/// Result of [TagflowStreamingBenchmarkSuite.run].
class StreamingBenchmarkSuiteResult {
  /// Creates a suite result.
  const StreamingBenchmarkSuiteResult({
    required this.generatedAt,
    required this.environment,
    required this.lanes,
  });

  /// When the suite ran.
  final DateTime generatedAt;

  /// Runtime environment details.
  final BenchmarkEnvironment environment;

  /// One result per lane.
  final List<StreamingBenchmarkLaneResult> lanes;

  /// JSON for the benchmark artifact.
  Map<String, Object?> toJson() => {
    'suite': 'streaming',
    'generatedAt': generatedAt.toIso8601String(),
    'environment': environment.toJson(),
    'lanes': [for (final lane in lanes) lane.toJson()],
  };
}

/// Timings for one lane.
class StreamingBenchmarkLaneResult {
  /// Creates a lane result.
  const StreamingBenchmarkLaneResult({
    required this.lane,
    required this.size,
    required this.stats,
  });

  /// Lane id.
  final String lane;

  /// Node count or input length the lane worked on.
  final int size;

  /// Per-operation timings in microseconds.
  final BenchmarkSampleStatistics stats;

  /// JSON for the benchmark artifact.
  Map<String, Object?> toJson() => {
    'lane': lane,
    'size': size,
    'operations': stats.samples.length,
    'medianMicros': stats.medianMicros,
    'p95Micros': stats.p95Micros,
    'maxMicros': stats.maxMicros,
    'meanMicros': stats.meanMicros,
  };
}

TagflowDocumentNode _section(int i, String version) {
  return TagflowDocumentNode.container(
    id: 's$i',
    children: [
      TagflowDocumentNode.heading(
        id: 's$i.h',
        level: 2,
        children: [TagflowDocumentNode.text(id: 's$i.h.t', text: 'Section $i')],
      ),
      _paragraph(i, version),
      TagflowDocumentNode.list(
        id: 's$i.l',
        ordered: false,
        children: [
          for (var item = 0; item < 3; item++)
            TagflowDocumentNode.listItem(
              id: 's$i.l.$item',
              children: [
                TagflowDocumentNode.text(id: 's$i.l.$item.t', text: 'Item'),
              ],
            ),
        ],
      ),
    ],
  );
}

TagflowDocumentNode _paragraph(int i, String version) {
  return TagflowDocumentNode.paragraph(
    id: 's$i.p',
    children: [
      TagflowDocumentNode.text(id: 's$i.p.a', text: 'Paragraph $version '),
      TagflowDocumentNode.inlineCode(id: 's$i.p.b', text: 'code'),
    ],
  );
}

int _countNodes(List<TagflowDocumentNode> nodes) {
  var count = 0;
  for (final node in nodes) {
    count += 1 + _countNodes(node.children);
  }
  return count;
}

class _StreamHost extends StatelessWidget {
  const _StreamHost({required this.stream});

  final TagflowMarkdownStream stream;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: TagflowMarkdownStreamView(stream: stream),
        ),
      ),
    );
  }
}

final _mixedMarkdown = [
  '# Streaming answer',
  '',
  for (var i = 0; i < 10; i++) ...[_paragraphLine(i), ''],
  for (var i = 0; i < 15; i++)
    '- List item $i with a [link](https://example.com)',
  '',
  '```dart',
  for (var i = 0; i < 75; i++) 'final value$i = compute($i);',
  '```',
  '',
  '| Name | Value |',
  '| --- | --- |',
  for (var i = 0; i < 10; i++) '| row $i | $i |',
  '',
].join('\n');

String _paragraphLine(int i) {
  return 'Paragraph $i explains a point with **bold**, *emphasis* and '
      '`code`, long enough to wrap across a couple of lines on a phone.';
}
