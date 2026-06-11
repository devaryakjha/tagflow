/// Fixture ids used by the profile-mode benchmark scaffold.
const List<String> profileBenchmarkFixtureIds = [
  'ai_answer_rich',
  'ai_answer_rich_md',
  'table_dense',
  'large_article',
  'table_stress',
];

/// Default fixture used by the manual benchmark route and integration test.
const String defaultProfileBenchmarkFixtureId = 'ai_answer_rich';

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
  for (final id in ['table_dense', 'large_article', 'table_stress'])
    id: ProfileBenchmarkFixture(
      id: id,
      source: BenchmarkFixtureSource(
        type: BenchmarkSourceType.html,
        assetPath: 'packages/tagflow_benchmarks/fixtures/html/$id.html',
      ),
    ),
};

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
  const ProfileBenchmarkFixture({required this.id, required this.source});

  /// Stable fixture id shared with `tagflow_benchmarks`.
  final String id;

  /// Source payload loaded by the benchmark host.
  final BenchmarkFixtureSource source;
}
