import 'dart:convert';
import 'dart:math';

import 'package:tagflow/tagflow.dart';
import 'package:tagflow_benchmarks/src/results/benchmark_result.dart';
import 'package:tagflow_benchmarks/src/results/environment_detector.dart';
import 'package:tagflow_benchmarks/src/results/sample_statistics.dart';

class NativeTransportBenchmarkFixture {
  const NativeTransportBenchmarkFixture({
    required this.id,
    required this.documentJson,
    required this.patchJson,
  });

  final String id;
  final Map<String, Object?> documentJson;
  final Map<String, Object?> patchJson;
}

const nativeTransportBenchmarkFixtures = <NativeTransportBenchmarkFixture>[
  NativeTransportBenchmarkFixture(
    id: 'native_ai_answer_patch',
    documentJson: <String, Object?>{
      'id': 'native-ai-answer',
      'schemaVersion': 1,
      'revision': 'rev-1',
      'metadata': <String, Object?>{
        'surface': 'answer_detail',
        'locale': 'en-IN',
      },
      'source': <String, Object?>{
        'kind': 'json',
        'adapter': 'native_block_v1',
        'uri': 'cms://answers/native-ai-answer',
      },
      'blocks': <Object?>[
        <String, Object?>{
          'id': 'title',
          'kind': 'heading',
          'attributes': <String, Object?>{'level': 2},
          'children': <Object?>[
            <String, Object?>{
              'id': 'title.text',
              'kind': 'text',
              'text': 'Native transport benchmark',
            },
          ],
        },
        <String, Object?>{
          'id': 'summary',
          'kind': 'paragraph',
          'children': <Object?>[
            <String, Object?>{
              'id': 'summary.a',
              'kind': 'text',
              'text': 'This fixture keeps transport overhead visible for ',
            },
            <String, Object?>{
              'id': 'summary.link',
              'kind': 'link',
              'attributes': <String, Object?>{
                'url': 'https://example.com/native-transport',
              },
              'children': <Object?>[
                <String, Object?>{
                  'id': 'summary.link.text',
                  'kind': 'text',
                  'text': 'structured content',
                },
              ],
            },
            <String, Object?>{
              'id': 'summary.b',
              'kind': 'text',
              'text': ' without exercising Flutter rendering.',
            },
          ],
        },
        <String, Object?>{
          'id': 'callout',
          'kind': 'callout',
          'attributes': <String, Object?>{'tone': 'info', 'variant': 'tip'},
          'children': <Object?>[
            <String, Object?>{
              'id': 'callout.text',
              'kind': 'paragraph',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'callout.text.body',
                  'kind': 'text',
                  'text': 'Numbers from this lane are local-run evidence only.',
                },
              ],
            },
          ],
        },
        <String, Object?>{
          'id': 'checks',
          'kind': 'list',
          'attributes': <String, Object?>{'ordered': true},
          'children': <Object?>[
            <String, Object?>{
              'id': 'checks.decode',
              'kind': 'listItem',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'checks.decode.text',
                  'kind': 'text',
                  'text': 'Decode native JSON.',
                },
              ],
            },
            <String, Object?>{
              'id': 'checks.adapt',
              'kind': 'listItem',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'checks.adapt.text',
                  'kind': 'text',
                  'text': 'Adapt blocks into the runtime document.',
                },
              ],
            },
          ],
        },
        <String, Object?>{
          'id': 'status.table',
          'kind': 'table',
          'children': <Object?>[
            <String, Object?>{
              'id': 'status.table.header',
              'kind': 'tableRow',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'status.table.header.phase',
                  'kind': 'tableCell',
                  'attributes': <String, Object?>{'header': true},
                  'children': <Object?>[
                    <String, Object?>{
                      'id': 'status.table.header.phase.text',
                      'kind': 'text',
                      'text': 'Phase',
                    },
                  ],
                },
                <String, Object?>{
                  'id': 'status.table.header.scope',
                  'kind': 'tableCell',
                  'attributes': <String, Object?>{'header': true},
                  'children': <Object?>[
                    <String, Object?>{
                      'id': 'status.table.header.scope.text',
                      'kind': 'text',
                      'text': 'Scope',
                    },
                  ],
                },
              ],
            },
            <String, Object?>{
              'id': 'status.table.row.decode',
              'kind': 'tableRow',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'status.table.row.decode.phase',
                  'kind': 'tableCell',
                  'children': <Object?>[
                    <String, Object?>{
                      'id': 'status.table.row.decode.phase.text',
                      'kind': 'text',
                      'text': 'decode',
                    },
                  ],
                },
                <String, Object?>{
                  'id': 'status.table.row.decode.scope',
                  'kind': 'tableCell',
                  'children': <Object?>[
                    <String, Object?>{
                      'id': 'status.table.row.decode.scope.text',
                      'kind': 'text',
                      'text': 'JSON maps to native blocks',
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    },
    patchJson: <String, Object?>{
      'id': 'native-ai-answer',
      'schemaVersion': 1,
      'baseRevision': 'rev-1',
      'revision': 'rev-2',
      'operations': <Object?>[
        <String, Object?>{
          'op': 'replace',
          'nodeId': 'summary',
          'block': <String, Object?>{
            'id': 'summary',
            'kind': 'paragraph',
            'children': <Object?>[
              <String, Object?>{
                'id': 'summary.updated.text',
                'kind': 'text',
                'text': 'Patch application keeps stable block identity.',
              },
            ],
          },
        },
        <String, Object?>{
          'op': 'append-children',
          'parentNodeId': 'checks',
          'blocks': <Object?>[
            <String, Object?>{
              'id': 'checks.patch',
              'kind': 'listItem',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'checks.patch.text',
                  'kind': 'text',
                  'text': 'Adapt native patches into runtime patches.',
                },
              ],
            },
          ],
        },
        <String, Object?>{
          'op': 'insert-before',
          'siblingNodeId': 'status.table',
          'blocks': <Object?>[
            <String, Object?>{
              'id': 'patch.note',
              'kind': 'paragraph',
              'children': <Object?>[
                <String, Object?>{
                  'id': 'patch.note.text',
                  'kind': 'text',
                  'text': 'This insertion exercises ordered runtime patches.',
                },
              ],
            },
          ],
        },
        <String, Object?>{'op': 'remove', 'nodeId': 'callout'},
      ],
    },
  ),
];

class TagflowNativeTransportBenchmarkSuite {
  const TagflowNativeTransportBenchmarkSuite({
    this.warmupIterations = 5,
    this.sampleCount = 10,
    this.codec = const TagflowNativeBlockCodec(),
    this.adapter = const TagflowNativeBlockAdapter(),
  });

  final int warmupIterations;
  final int sampleCount;
  final TagflowNativeBlockCodec codec;
  final TagflowNativeBlockAdapter adapter;

  NativeTransportBenchmarkSuiteResult run({
    Iterable<NativeTransportBenchmarkFixture>? fixtures,
  }) {
    final selectedFixtures = List<NativeTransportBenchmarkFixture>.unmodifiable(
      fixtures ?? nativeTransportBenchmarkFixtures,
    );

    final fixtureResults = selectedFixtures
        .map(_benchmarkFixture)
        .toList(growable: false);

    return NativeTransportBenchmarkSuiteResult(
      suite: 'native_transport',
      generatedAt: DateTime.now().toUtc(),
      environment: detectBenchmarkEnvironment(),
      warmupIterations: warmupIterations,
      sampleCount: sampleCount,
      fixtureResults: fixtureResults,
    );
  }

  NativeTransportBenchmarkFixtureResult _benchmarkFixture(
    NativeTransportBenchmarkFixture fixture,
  ) {
    for (var index = 0; index < warmupIterations; index++) {
      _runTransport(fixture);
    }

    final phaseSamples = <String, List<int>>{
      'decodeDocument': <int>[],
      'adaptDocument': <int>[],
      'decodePatchEnvelope': <int>[],
      'adaptPatches': <int>[],
      'applyPatches': <int>[],
      'totalTransport': <int>[],
    };

    late TagflowDocument updatedDocument;
    late TagflowNativeBlockPatchEnvelope patchEnvelope;
    for (var index = 0; index < sampleCount; index++) {
      final sample = _runTransport(fixture);
      updatedDocument = sample.updatedDocument;
      patchEnvelope = sample.patchEnvelope;
      for (final entry in sample.phaseMicros.entries) {
        phaseSamples[entry.key]!.add(entry.value);
      }
    }

    return NativeTransportBenchmarkFixtureResult(
      fixtureId: fixture.id,
      documentBytes: utf8.encode(jsonEncode(fixture.documentJson)).length,
      patchBytes: utf8.encode(jsonEncode(fixture.patchJson)).length,
      nodeCount: _countNodes(updatedDocument),
      patchOperationCount: patchEnvelope.operations.length,
      phaseResults: [
        for (final entry in phaseSamples.entries)
          _phaseResult(entry.key, entry.value),
      ],
    );
  }

  _NativeTransportSample _runTransport(
    NativeTransportBenchmarkFixture fixture,
  ) {
    final totalStopwatch = Stopwatch()..start();

    final decodeDocumentStopwatch = Stopwatch()..start();
    final nativeDocument = codec.decodeDocument(fixture.documentJson);
    decodeDocumentStopwatch.stop();

    final adaptDocumentStopwatch = Stopwatch()..start();
    final runtimeDocument = adapter.adapt(nativeDocument);
    adaptDocumentStopwatch.stop();

    final decodePatchStopwatch = Stopwatch()..start();
    final patchEnvelope = codec.decodePatchEnvelope(fixture.patchJson);
    decodePatchStopwatch.stop();

    final adaptPatchesStopwatch = Stopwatch()..start();
    final runtimePatches = adapter.adaptPatches(patchEnvelope.operations);
    adaptPatchesStopwatch.stop();

    final applyPatchesStopwatch = Stopwatch()..start();
    final updatedDocument = runtimeDocument.applyPatches(runtimePatches);
    applyPatchesStopwatch.stop();

    totalStopwatch.stop();

    return _NativeTransportSample(
      patchEnvelope: patchEnvelope,
      updatedDocument: updatedDocument,
      phaseMicros: <String, int>{
        'decodeDocument': max(decodeDocumentStopwatch.elapsedMicroseconds, 1),
        'adaptDocument': max(adaptDocumentStopwatch.elapsedMicroseconds, 1),
        'decodePatchEnvelope': max(decodePatchStopwatch.elapsedMicroseconds, 1),
        'adaptPatches': max(adaptPatchesStopwatch.elapsedMicroseconds, 1),
        'applyPatches': max(applyPatchesStopwatch.elapsedMicroseconds, 1),
        'totalTransport': max(totalStopwatch.elapsedMicroseconds, 1),
      },
    );
  }

  NativeTransportBenchmarkPhaseResult _phaseResult(
    String phaseId,
    List<int> samples,
  ) {
    final stats = BenchmarkSampleStatistics.fromSamples(samples);
    return NativeTransportBenchmarkPhaseResult(
      phaseId: phaseId,
      sampleMicros: stats.samples,
      medianMicros: stats.medianMicros,
      p95Micros: stats.p95Micros,
      minMicros: stats.minMicros,
      maxMicros: stats.maxMicros,
      meanMicros: stats.meanMicros,
      coefficientOfVariation: stats.coefficientOfVariation,
    );
  }

  int _countNodes(TagflowDocument document) {
    var count = 0;
    for (final child in document.children) {
      count += _countNode(child);
    }
    return count;
  }

  int _countNode(TagflowDocumentNode node) {
    var count = 1;
    for (final child in node.children) {
      count += _countNode(child);
    }
    return count;
  }
}

class _NativeTransportSample {
  const _NativeTransportSample({
    required this.patchEnvelope,
    required this.updatedDocument,
    required this.phaseMicros,
  });

  final TagflowNativeBlockPatchEnvelope patchEnvelope;
  final TagflowDocument updatedDocument;
  final Map<String, int> phaseMicros;
}
