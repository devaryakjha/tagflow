/// Fixture ids used by the profile-mode benchmark scaffold.
const List<String> profileBenchmarkFixtureIds = [
  'ai_answer_rich',
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
  for (final id in profileBenchmarkFixtureIds)
    id: ProfileBenchmarkFixture(
      id: id,
      htmlAssetPath: 'packages/tagflow_benchmarks/fixtures/html/$id.html',
    ),
};

/// Runtime fixture descriptor for the example-app profile benchmark route.
final class ProfileBenchmarkFixture {
  /// Creates a profile benchmark fixture descriptor.
  const ProfileBenchmarkFixture({
    required this.id,
    required this.htmlAssetPath,
  });

  /// Stable fixture id shared with `tagflow_benchmarks`.
  final String id;

  /// Flutter asset path for the fixture HTML.
  final String htmlAssetPath;
}
