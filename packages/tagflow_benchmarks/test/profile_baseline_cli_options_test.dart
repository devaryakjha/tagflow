import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/src/profile/profile_baseline_cli_options.dart';

void main() {
  test('parses renderer and fixture matrix options when pair is absent', () {
    final options = ProfileBaselineCliOptions.parse(const [
      '--renderer=tagflow,flutter_html',
      '--fixture=ai_answer_rich,table_dense',
      '--repeat=2',
    ], environment: const {});

    expect(options.pairs, isNull);
    expect(options.renderers, <String>['tagflow', 'flutter_html']);
    expect(options.fixtures, <String>['ai_answer_rich', 'table_dense']);
    expect(options.repeatCount, 2);
  });

  test('parses ordered profile pairs and derives manifest selectors', () {
    final pairValue = [
      'tagflow_semantic:streaming_ai_chunks',
      'tagflow_semantic_patch:streaming_ai_patches',
      'tagflow_semantic:large_article',
    ].join(',');
    final options = ProfileBaselineCliOptions.parse([
      '--pair=$pairValue',
    ], environment: const {});

    expect(
      options.pairs!.map((pair) => '${pair.renderer}:${pair.fixture}'),
      <String>[
        'tagflow_semantic:streaming_ai_chunks',
        'tagflow_semantic_patch:streaming_ai_patches',
        'tagflow_semantic:large_article',
      ],
    );
    expect(options.renderers, <String>[
      'tagflow_semantic',
      'tagflow_semantic_patch',
    ]);
    expect(options.fixtures, <String>[
      'streaming_ai_chunks',
      'streaming_ai_patches',
      'large_article',
    ]);
  });

  test('parses profile pairs from environment', () {
    final pairValue = [
      'tagflow_semantic:streaming_ai_chunks',
      'tagflow_semantic_patch:streaming_ai_patches',
    ].join(',');
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: {'TAGFLOW_PROFILE_PAIR': pairValue},
    );

    expect(options.pairs, hasLength(2));
    expect(options.pairs!.last.renderer, 'tagflow_semantic_patch');
    expect(options.pairs!.last.fixture, 'streaming_ai_patches');
  });

  test('parses stable run id from environment', () {
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {'TAGFLOW_PROFILE_RUN_ID': 'semantic-pair-r1'},
    );

    expect(options.runId, 'semantic-pair-r1');
  });

  test('rejects malformed profile pairs', () {
    expect(
      () => ProfileBaselineCliOptions.parse(const [
        '--pair=tagflow_semantic_patch',
      ], environment: const {}),
      throwsFormatException,
    );
  });
}
