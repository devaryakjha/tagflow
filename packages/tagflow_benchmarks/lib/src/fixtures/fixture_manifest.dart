import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:tagflow_benchmarks/src/io/package_paths.dart';

final List<BenchmarkFixture> benchmarkFixtures =
    List<BenchmarkFixture>.unmodifiable(<BenchmarkFixture>[
      const BenchmarkFixture(
        id: 'smoke_short_html',
        htmlRelativePath: 'fixtures/html/smoke_short_html.html',
        htmlSha256:
            '8b639ef98673679300e1fa7f19606e77118a8918937bfe6faabff66e7adab704',
      ),
      const BenchmarkFixture(
        id: 'ai_answer_rich',
        htmlRelativePath: 'fixtures/html/ai_answer_rich.html',
        htmlSha256:
            '8de2eb4b3a4eb244b0e612ebfda1874a405cd84c5263d1c6656c96330f8bb16d',
        markdownRelativePath: 'fixtures/markdown/ai_answer_rich.md',
        markdownSha256:
            '11c5dd5b3d250aed3ead99e6d4ec5ec9528ae79371a5cc62ad2b92c4b706e5e3',
      ),
      const BenchmarkFixture(
        id: 'table_dense',
        htmlRelativePath: 'fixtures/html/table_dense.html',
        htmlSha256:
            '97453c082ed6b64f0d45043383904768c6e87c2edf064a9cb13ad8bcf1315fa4',
      ),
      const BenchmarkFixture(
        id: 'large_article',
        htmlRelativePath: 'fixtures/html/large_article.html',
        htmlSha256:
            'a095cd3b84c010ff3d69d8776421f5c74fb039073fcc503d0b5d3693320372e4',
      ),
      const BenchmarkFixture(
        id: 'deep_nested_lists',
        htmlRelativePath: 'fixtures/html/deep_nested_lists.html',
        htmlSha256:
            '78b0510dace4a84e219b84c070d361e95fdb88be2554ea4874f25e15f1a1ca3d',
      ),
    ]);

final Map<String, BenchmarkFixture> _fixturesById = <String, BenchmarkFixture>{
  for (final fixture in benchmarkFixtures) fixture.id: fixture,
};

BenchmarkFixture fixtureById(String id) {
  final fixture = _fixturesById[id];
  if (fixture == null) {
    throw ArgumentError.value(id, 'id', 'Unknown benchmark fixture id.');
  }
  return fixture;
}

class BenchmarkFixture {
  const BenchmarkFixture({
    required this.id,
    required this.htmlRelativePath,
    required this.htmlSha256,
    this.markdownRelativePath,
    this.markdownSha256,
  });

  final String id;
  final String htmlRelativePath;
  final String htmlSha256;
  final String? markdownRelativePath;
  final String? markdownSha256;

  String get html => _readRelativeFile(htmlRelativePath);

  String? get markdown {
    final path = markdownRelativePath;
    if (path == null) {
      return null;
    }
    return _readRelativeFile(path);
  }

  String computeHtmlSha256() => _sha256Hex(html);

  String? computeMarkdownSha256() {
    final contents = markdown;
    if (contents == null) {
      return null;
    }
    return _sha256Hex(contents);
  }

  String _readRelativeFile(String relativePath) {
    final packageRoot = resolveBenchmarkPackageRoot();
    final file = File(p.join(packageRoot.path, relativePath));
    if (!file.existsSync()) {
      throw StateError('Missing fixture file: ${file.path}');
    }
    return file.readAsStringSync();
  }

  String _sha256Hex(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}
