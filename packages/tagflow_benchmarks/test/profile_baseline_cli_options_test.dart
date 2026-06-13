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
      'tagflow_semantic:streaming_ai_authored_insertions',
      'tagflow_semantic_patch:streaming_ai_authored_insertion_patches',
    ].join(',');
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: {'TAGFLOW_PROFILE_PAIR': pairValue},
    );

    expect(options.pairs, hasLength(2));
    expect(options.pairs!.last.renderer, 'tagflow_semantic_patch');
    expect(
      options.pairs!.last.fixture,
      'streaming_ai_authored_insertion_patches',
    );
  });

  test('parses stable run id from environment', () {
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {'TAGFLOW_PROFILE_RUN_ID': 'semantic-pair-r1'},
    );

    expect(options.runId, 'semantic-pair-r1');
  });

  test('parses profile memory opt-in from cli and environment', () {
    final cliOptions = ProfileBaselineCliOptions.parse(const [
      '--profile-memory=true',
    ], environment: const {});
    final envOptions = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {'TAGFLOW_PROFILE_MEMORY': 'yes'},
    );

    expect(cliOptions.profileMemory, isTrue);
    expect(envOptions.profileMemory, isTrue);
  });

  test('parses profile checkpoint hold-open opt-in and seconds', () {
    final cliOptions = ProfileBaselineCliOptions.parse(const [
      '--profile-hold-open=true',
      '--profile-hold-open-seconds=45',
    ], environment: const {});
    final envOptions = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {'TAGFLOW_PROFILE_HOLD_OPEN_SECONDS': '30'},
    );

    expect(cliOptions.profileHoldOpen, isTrue);
    expect(cliOptions.profileHoldOpenSeconds, 45);
    expect(envOptions.profileHoldOpen, isTrue);
    expect(envOptions.profileHoldOpenSeconds, 30);
  });

  test('uses the default hold-open duration when enabled without seconds', () {
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {'TAGFLOW_PROFILE_HOLD_OPEN': 'true'},
    );

    expect(options.profileHoldOpen, isTrue);
    expect(options.profileHoldOpenSeconds, 120);
  });

  test('parses profile run timeout from cli and environment', () {
    final cliOptions = ProfileBaselineCliOptions.parse(const [
      '--run-timeout-seconds=180',
    ], environment: const {});
    final envOptions = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {'TAGFLOW_PROFILE_RUN_TIMEOUT_SECONDS': '240'},
    );

    expect(cliOptions.runTimeout, const Duration(seconds: 180));
    expect(envOptions.runTimeout, const Duration(seconds: 240));
  });

  test('defaults to observed-host viewport mode', () {
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {},
    );

    expect(options.profileViewportConfiguration.mode.name, 'observedHost');
    expect(options.profileViewportConfiguration.syntheticViewport, isNull);
  });

  test('parses synthetic viewport mode from environment', () {
    final options = ProfileBaselineCliOptions.parse(
      const [],
      environment: const {
        'TAGFLOW_PROFILE_VIEWPORT_MODE': 'synthetic',
        'TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE': '800x600',
        'TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO': '2.0',
      },
    );

    final viewport = options.profileViewportConfiguration.syntheticViewport!;
    expect(options.profileViewportConfiguration.mode.name, 'synthetic');
    expect(viewport.logicalWidth, 800);
    expect(viewport.logicalHeight, 600);
    expect(viewport.devicePixelRatio, 2);
  });

  test('rejects malformed profile pairs', () {
    expect(
      () => ProfileBaselineCliOptions.parse(const [
        '--pair=tagflow_semantic_patch',
      ], environment: const {}),
      throwsFormatException,
    );
  });

  test('rejects non-positive profile checkpoint hold-open seconds', () {
    expect(
      () => ProfileBaselineCliOptions.parse(const [
        '--profile-hold-open-seconds=0',
      ], environment: const {}),
      throwsFormatException,
    );
  });

  test('rejects non-positive profile run timeout seconds', () {
    expect(
      () => ProfileBaselineCliOptions.parse(const [
        '--run-timeout-seconds=0',
      ], environment: const {}),
      throwsFormatException,
    );
  });

  test('rejects partial synthetic viewport configuration', () {
    expect(
      () => ProfileBaselineCliOptions.parse(
        const [],
        environment: const {
          'TAGFLOW_PROFILE_VIEWPORT_MODE': 'synthetic',
          'TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE': '800x600',
        },
      ),
      throwsFormatException,
    );
  });

  test('rejects non-finite synthetic viewport values', () {
    expect(
      () => ProfileBaselineCliOptions.parse(
        const [],
        environment: const {
          'TAGFLOW_PROFILE_VIEWPORT_MODE': 'synthetic',
          'TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE': '800xNaN',
          'TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO': '2.0',
        },
      ),
      throwsFormatException,
    );
    expect(
      () => ProfileBaselineCliOptions.parse(
        const [],
        environment: const {
          'TAGFLOW_PROFILE_VIEWPORT_MODE': 'synthetic',
          'TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE': '800x600',
          'TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO': 'Infinity',
        },
      ),
      throwsFormatException,
    );
  });

  test('rejects synthetic inputs in observed-host viewport mode', () {
    expect(
      () => ProfileBaselineCliOptions.parse(
        const [],
        environment: const {
          'TAGFLOW_PROFILE_SYNTHETIC_LOGICAL_SIZE': '800x600',
          'TAGFLOW_PROFILE_SYNTHETIC_DEVICE_PIXEL_RATIO': '2.0',
        },
      ),
      throwsFormatException,
    );
  });
}
