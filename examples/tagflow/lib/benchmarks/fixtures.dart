/// Fixture ids used by the profile-mode benchmark scaffold.
const List<String> profileBenchmarkFixtureIds = [
  'ai_answer_rich',
  'ai_answer_rich_md',
  'table_dense',
  'large_article',
  'table_stress',
  'streaming_ai_chunks',
  authoredInsertionBenchmarkFixtureId,
  semanticPatchBenchmarkFixtureId,
  authoredInsertionSemanticPatchBenchmarkFixtureId,
];

/// Default fixture used by the manual benchmark route and integration test.
const String defaultProfileBenchmarkFixtureId = 'ai_answer_rich';

/// Fixture id for semantic document patch streaming.
const String semanticPatchBenchmarkFixtureId = 'streaming_ai_patches';

/// Fixture id for authored HTML insertion streaming.
const String authoredInsertionBenchmarkFixtureId =
    'streaming_ai_authored_insertions';

/// Fixture id for authored HTML insertion patches.
const String authoredInsertionSemanticPatchBenchmarkFixtureId =
    'streaming_ai_authored_insertion_patches';

/// Renderer id for semantic document patch streaming.
const String semanticPatchBenchmarkRendererId = 'tagflow_semantic_patch';

/// Progressive HTML snapshots for authored-ID insertion streaming.
const List<String> authoredInsertionStreamingHtmlSnapshots = [
  '''
<article data-tagflow-id="answer">
  <p data-tagflow-id="summary">Summary</p>
  <p data-tagflow-id="details">Details</p>
</article>
''',
  '''
<article data-tagflow-id="answer">
  <blockquote data-tagflow-id="callout">
    <p>Callout</p>
  </blockquote>
  <p data-tagflow-id="summary">Summary</p>
  <p data-tagflow-id="details">Details</p>
</article>
''',
  '''
<article data-tagflow-id="answer">
  <p data-tagflow-id="context">Context</p>
  <blockquote data-tagflow-id="callout">
    <p>Callout</p>
  </blockquote>
  <p data-tagflow-id="summary">Summary</p>
  <p data-tagflow-id="details">Details</p>
</article>
''',
  '''
<article data-tagflow-id="answer">
  <h2 data-tagflow-id="lead">Lead</h2>
  <p data-tagflow-id="context">Context</p>
  <blockquote data-tagflow-id="callout">
    <p>Callout</p>
  </blockquote>
  <p data-tagflow-id="summary">Summary</p>
  <p data-tagflow-id="details">Details</p>
</article>
''',
];

/// Resolves a profile benchmark fixture by id.
ProfileBenchmarkFixture profileBenchmarkFixtureById(String id) {
  final fixture = _profileBenchmarkFixtures[id];
  if (fixture == null) {
    throw ArgumentError.value(id, 'id', 'Unknown profile benchmark fixture.');
  }
  return fixture;
}

final Map<String, ProfileBenchmarkFixture> _profileBenchmarkFixtures = {
  'ai_answer_rich': const ProfileBenchmarkFixture(
    id: 'ai_answer_rich',
    source: BenchmarkFixtureSource(
      type: BenchmarkSourceType.html,
      assetPath:
          'packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html',
    ),
  ),
  'ai_answer_rich_md': const ProfileBenchmarkFixture(
    id: 'ai_answer_rich_md',
    source: BenchmarkFixtureSource(
      type: BenchmarkSourceType.markdown,
      assetPath:
          'packages/tagflow_benchmarks/fixtures/markdown/ai_answer_rich.md',
    ),
  ),
  'streaming_ai_chunks': const ProfileBenchmarkFixture(
    id: 'streaming_ai_chunks',
    source: BenchmarkFixtureSource(
      type: BenchmarkSourceType.html,
      assetPath:
          'packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html',
    ),
    scenario: BenchmarkScenario.streamingChunks,
  ),
  authoredInsertionBenchmarkFixtureId: const ProfileBenchmarkFixture(
    id: authoredInsertionBenchmarkFixtureId,
    source: BenchmarkFixtureSource(
      type: BenchmarkSourceType.html,
      assetPath:
          'packages/tagflow_benchmarks/fixtures/html/'
          'streaming_ai_authored_insertions.html',
    ),
    scenario: BenchmarkScenario.streamingChunks,
    rendererIds: {'tagflow_semantic'},
  ),
  semanticPatchBenchmarkFixtureId: const ProfileBenchmarkFixture(
    id: semanticPatchBenchmarkFixtureId,
    source: BenchmarkFixtureSource(
      type: BenchmarkSourceType.html,
      assetPath:
          'packages/tagflow_benchmarks/fixtures/html/ai_answer_rich.html',
    ),
    scenario: BenchmarkScenario.semanticPatchStreaming,
    rendererIds: {semanticPatchBenchmarkRendererId},
  ),
  authoredInsertionSemanticPatchBenchmarkFixtureId:
      const ProfileBenchmarkFixture(
        id: authoredInsertionSemanticPatchBenchmarkFixtureId,
        source: BenchmarkFixtureSource(
          type: BenchmarkSourceType.html,
          assetPath:
              'packages/tagflow_benchmarks/fixtures/html/'
              'streaming_ai_authored_insertions.html',
        ),
        scenario: BenchmarkScenario.semanticPatchStreaming,
        rendererIds: {semanticPatchBenchmarkRendererId},
      ),
  for (final id in ['table_dense', 'large_article', 'table_stress'])
    id: ProfileBenchmarkFixture(
      id: id,
      source: BenchmarkFixtureSource(
        type: BenchmarkSourceType.html,
        assetPath: 'packages/tagflow_benchmarks/fixtures/html/$id.html',
      ),
    ),
};

/// Benchmark interaction shape for a fixture.
enum BenchmarkScenario {
  /// Render the fixture once, then measure scrolling.
  staticDocument,

  /// Re-render progressively larger chunks of one source document.
  streamingChunks,

  /// Apply semantic document patches to stream already-adapted content.
  semanticPatchStreaming,
}

/// Supported benchmark source formats.
enum BenchmarkSourceType {
  /// Hypertext markup rendered by HTML-native engines.
  html,

  /// Markdown text rendered by markdown-native engines.
  markdown,
}

/// Asset-backed source descriptor for a benchmark fixture.
final class BenchmarkFixtureSource {
  /// Creates a benchmark fixture source.
  const BenchmarkFixtureSource({required this.type, required this.assetPath});

  /// Source content type.
  final BenchmarkSourceType type;

  /// Flutter asset path for the fixture source.
  final String assetPath;
}

/// Runtime fixture descriptor for the example-app profile benchmark route.
final class ProfileBenchmarkFixture {
  /// Creates a profile benchmark fixture descriptor.
  const ProfileBenchmarkFixture({
    required this.id,
    required this.source,
    this.scenario = BenchmarkScenario.staticDocument,
    this.rendererIds = const {},
  });

  /// Stable fixture id shared with `tagflow_benchmarks`.
  final String id;

  /// Source payload loaded by the benchmark host.
  final BenchmarkFixtureSource source;

  /// Interaction pattern used by automated profile benchmarks.
  final BenchmarkScenario scenario;

  /// Optional explicit renderer ids accepted by this fixture.
  final Set<String> rendererIds;

  /// Whether this fixture accepts [rendererId].
  bool supportsRendererId(String rendererId) {
    return rendererIds.isEmpty || rendererIds.contains(rendererId);
  }
}

/// One HTML snapshot used by a streaming benchmark scenario.
final class BenchmarkStreamingSnapshot {
  /// Creates a streaming HTML snapshot.
  const BenchmarkStreamingSnapshot({
    required this.chunk,
    required this.fraction,
    required this.html,
  });

  /// 1-based update index.
  final int chunk;

  /// Fraction-like progress marker for report payloads.
  final double fraction;

  /// HTML rendered for this update.
  final String html;

  /// Input length used by benchmark reports.
  int get inputLength => html.length;
}

/// Resolves ordered HTML snapshots for a streaming benchmark fixture.
List<BenchmarkStreamingSnapshot> benchmarkStreamingSnapshots(
  String fixtureId,
  String fullDocument,
) {
  if (fixtureId == authoredInsertionBenchmarkFixtureId ||
      fixtureId == authoredInsertionSemanticPatchBenchmarkFixtureId) {
    final snapshotCount = authoredInsertionStreamingHtmlSnapshots.length;
    return List<BenchmarkStreamingSnapshot>.unmodifiable([
      for (final indexed in authoredInsertionStreamingHtmlSnapshots.indexed)
        BenchmarkStreamingSnapshot(
          chunk: indexed.$1 + 1,
          fraction: (indexed.$1 + 1) / snapshotCount,
          html: indexed.$2,
        ),
    ]);
  }

  const streamingChunkFractions = [0.25, 0.5, 0.75, 1.0];
  return List<BenchmarkStreamingSnapshot>.unmodifiable([
    for (final indexed in streamingChunkFractions.indexed)
      BenchmarkStreamingSnapshot(
        chunk: indexed.$1 + 1,
        fraction: indexed.$2,
        html: _chunkDocument(fullDocument, indexed.$2),
      ),
  ]);
}

String _chunkDocument(String document, double fraction) {
  if (fraction >= 1) {
    return document;
  }

  final targetLength = (document.length * fraction).round();
  final nextBoundary = document.indexOf('>', targetLength);
  if (nextBoundary == -1) {
    return document;
  }

  return '${document.substring(0, nextBoundary + 1)}</article>';
}
