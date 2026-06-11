import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_benchmarks/tagflow_benchmarks.dart';

void main() {
  group('benchmarkFixtures', () {
    test('includes the required fixture ids', () {
      expect(
        benchmarkFixtures.map((fixture) => fixture.id),
        containsAll(<String>[
          'smoke_short_html',
          'ai_answer_rich',
          'table_dense',
          'large_article',
          'deep_nested_lists',
        ]),
      );
    });

    test('loads non-empty deterministic local-only HTML fixtures', () {
      for (final fixture in benchmarkFixtures) {
        expect(fixture.html, isNotEmpty, reason: fixture.id);
        expect(fixture.htmlSha256, hasLength(64), reason: fixture.id);
        expect(
          fixture.computeHtmlSha256(),
          fixture.htmlSha256,
          reason: fixture.id,
        );
        expect(fixture.html, isNot(contains('http://')), reason: fixture.id);
        expect(fixture.html, isNot(contains('https://')), reason: fixture.id);
        expect(fixture.html, isNot(contains('<script')), reason: fixture.id);
        expect(fixture.html, isNot(contains('<iframe')), reason: fixture.id);
      }
    });

    test('exposes markdown when a paired source exists', () {
      final fixture = fixtureById('ai_answer_rich');

      expect(fixture.markdown, isNotNull);
      expect(fixture.markdown, isNotEmpty);
      expect(fixture.markdownSha256, hasLength(64));
      expect(fixture.computeMarkdownSha256(), fixture.markdownSha256);
    });

    test('returns fixtures by id', () {
      expect(() => fixtureById('table_dense'), returnsNormally);
      expect(
        () => fixtureById('missing_fixture'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
