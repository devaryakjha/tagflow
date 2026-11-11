import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regenerate the snapshot after an intended API change with:
///
/// ```sh
/// TAGFLOW_UPDATE_API=1 flutter test test/src/public_api/api_snapshot_test.dart
/// ```
const _snapshotPath = 'test/src/public_api/tagflow_api.txt';

void main() {
  test('should match the public API snapshot of package:tagflow', () {
    final actual = '${_publicApi('lib/tagflow.dart').join('\n')}\n';
    final snapshot = File(_snapshotPath);

    if (Platform.environment['TAGFLOW_UPDATE_API'] == '1') {
      snapshot.writeAsStringSync(actual);
    }

    expect(
      actual,
      snapshot.readAsStringSync(),
      reason:
          'The public API of package:tagflow changed. If that is intended, '
          'regenerate $_snapshotPath with TAGFLOW_UPDATE_API=1, add a '
          'CHANGELOG entry, and update the API freeze spec.',
    );
  });
}

final _export = RegExp(
  r"""^export\s+'([^']+)'(?:\s+(show|hide)\s+([\w\s,]+))?;""",
  multiLine: true,
);
final _typeDeclaration = RegExp(
  r'^(?:(?:abstract|base|final|interface|sealed|mixin)\s+)*'
  r'(class|enum|mixin|extension type|extension|typedef)\s+(\w+)',
);
final _topLevelValue = RegExp(
  r'^(?:const|final|late\s+final)\s+(?:[\w<>?, ]+\s+)?(\w+)\s*=',
);
final _topLevelFunction = RegExp(r'^[\w<>?, ]+\s+(\w+)\s*(?:<[^>]*>)?\(');
final _member = RegExp(
  r'^  (?=\S)(?:@\w+(?:\([^)]*\))?\s+)?'
  r'(?:(?:static|const|final|factory|late|external|abstract|covariant)\s+)*'
  r'(?:[\w<>?, .\[\]]+?\s+)??'
  r'(?:(get|set|operator)\s+)?'
  r'([A-Za-z]\w*(?:\.[A-Za-z]\w*)?|\[\]=?|==|[-+*/<>~]+)'
  r'\s*(?:<[^>]*>)?\s*(?:\(|=|;|=>|\{)',
);
final _enumValue = RegExp(r'^  ([a-z]\w*)\s*[,;(]?\s*$');
const _statementWords = {
  'return',
  'if',
  'for',
  'while',
  'switch',
  'throw',
  'assert',
  'super',
  'this',
  'case',
  'else',
  'await',
  'yield',
};

/// Public declarations reachable from [libraryPath], one per line, sorted.
List<String> _publicApi(String libraryPath) {
  final entries = <String>{};
  _collect(File(libraryPath).absolute.path, null, null, entries, {});
  return entries.toList()..sort();
}

void _collect(
  String path,
  Set<String>? show,
  Set<String>? hide,
  Set<String> entries,
  Set<String> visiting,
) {
  final key = '$path|$show|$hide';
  if (!visiting.add(key)) return;
  final source = File(path).readAsStringSync();

  for (final match in _export.allMatches(source)) {
    final uri = match.group(1)!;
    final target = uri.startsWith('package:tagflow/')
        ? '${Directory.current.path}/lib/'
              '${uri.substring('package:tagflow/'.length)}'
        : File(path).parent.uri.resolve(uri).toFilePath();
    final names = match
        .group(3)
        ?.split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    _collect(
      target,
      match.group(2) == 'show' ? _narrow(show, names) : show,
      match.group(2) == 'hide' ? {...?hide, ...?names} : hide,
      entries,
      visiting,
    );
  }

  bool visible(String name) =>
      !name.startsWith('_') &&
      (show == null || show.contains(name)) &&
      !(hide?.contains(name) ?? false);

  String? owner;
  var isEnum = false;
  var inEnumValues = false;
  for (final line in source.split('\n')) {
    if (line.isEmpty || line.startsWith('//') || line.startsWith('  //')) {
      continue;
    }
    if (!line.startsWith(' ')) {
      owner = null;
      if (line.startsWith('}') || line.startsWith('@')) continue;
      final type = _typeDeclaration.firstMatch(line);
      if (type != null) {
        final name = type.group(2)!;
        if (name != 'on' && visible(name)) {
          owner = name;
          isEnum = type.group(1) == 'enum';
          inEnumValues = isEnum;
          entries.add('${type.group(1)} $name');
        }
        continue;
      }
      final value = _topLevelValue.firstMatch(line);
      final function = _topLevelFunction.firstMatch(line);
      final name = value?.group(1) ?? function?.group(1);
      if (name != null && visible(name) && !line.startsWith('export')) {
        entries.add('top-level $name');
      }
      continue;
    }
    if (owner == null) continue;
    if (inEnumValues) {
      final value = _enumValue.firstMatch(line);
      if (value != null) {
        entries.add('$owner.${value.group(1)}');
        if (line.trimRight().endsWith(';')) inEnumValues = false;
        continue;
      }
    }
    final member = _member.firstMatch(line);
    if (member == null) continue;
    final name = member.group(2)!;
    final kind = member.group(1);
    if (name.startsWith('_') || name.contains('._')) continue;
    if (_statementWords.contains(name)) continue;
    if (name == owner || name.startsWith('$owner.')) {
      entries.add(
        '$owner.new ${name == owner ? '' : name.substring(owner.length + 1)}'
            .trimRight(),
      );
      continue;
    }
    entries.add('$owner.${kind == null ? '' : '$kind '}$name');
  }
}

Set<String>? _narrow(Set<String>? current, Set<String>? names) {
  if (names == null) return current;
  return current == null ? names : current.intersection(names);
}
