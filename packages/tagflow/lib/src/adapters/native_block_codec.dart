import 'package:meta/meta.dart';
import 'package:tagflow/src/adapters/native_block.dart';
import 'package:tagflow/src/adapters/native_block_patch.dart';
import 'package:tagflow/src/runtime/metadata.dart';
import 'package:tagflow/src/runtime/source.dart';

/// JSON codec for the native block adapter transport shape.
final class TagflowNativeBlockCodec {
  /// Creates a native block JSON codec.
  const TagflowNativeBlockCodec();

  /// Decodes a native block document from JSON-like map data.
  TagflowNativeBlockDocument decodeDocument(Map<String, Object?> json) {
    return TagflowNativeBlockDocument(
      id: _requiredString(json, 'id', path: 'document.id'),
      schemaVersion: _requiredPositiveInt(
        json,
        'schemaVersion',
        path: 'document.schemaVersion',
      ),
      revision: _optionalString(json, 'revision', path: 'document.revision'),
      metadata: _decodeMetadata(json['metadata'], path: 'document.metadata'),
      source: _decodeSource(json['source'], path: 'document.source'),
      blocks: _decodeBlocks(json['blocks'], path: 'document.blocks'),
    );
  }

  /// Encodes [document] into the supported native block JSON shape.
  Map<String, Object?> encodeDocument(TagflowNativeBlockDocument document) {
    return {
      'id': document.id,
      'schemaVersion': document.schemaVersion,
      if (document.revision != null) 'revision': document.revision,
      if (!document.metadata.isEmpty)
        'metadata': _encodeMetadata(document.metadata),
      if (document.source != null) 'source': _encodeSource(document.source!),
      'blocks': [for (final block in document.blocks) encodeBlock(block)],
    };
  }

  /// Decodes a native block from JSON-like map data.
  TagflowNativeBlock decodeBlock(Map<String, Object?> json) {
    return _decodeBlock(json, path: 'block');
  }

  /// Encodes [block] into the supported native block JSON shape.
  Map<String, Object?> encodeBlock(TagflowNativeBlock block) {
    return {
      'id': block.id,
      'kind': block.kind.name,
      if (block.text != null) 'text': block.text,
      if (block.attributes.isNotEmpty)
        'attributes': _normalizeJsonObject(
          block.attributes,
          path: 'block.attributes',
        ),
      if (block.children.isNotEmpty)
        'children': [for (final child in block.children) encodeBlock(child)],
      if (!block.metadata.isEmpty) 'metadata': _encodeMetadata(block.metadata),
      if (block.source != null) 'source': _encodeSource(block.source!),
    };
  }

  /// Decodes a native block patch envelope from JSON-like map data.
  TagflowNativeBlockPatchEnvelope decodePatchEnvelope(
    Map<String, Object?> json,
  ) {
    return TagflowNativeBlockPatchEnvelope(
      documentId: _requiredString(json, 'id', path: 'patch.id'),
      schemaVersion: _requiredPositiveInt(
        json,
        'schemaVersion',
        path: 'patch.schemaVersion',
      ),
      baseRevision: _optionalString(
        json,
        'baseRevision',
        path: 'patch.baseRevision',
      ),
      revision: _optionalString(json, 'revision', path: 'patch.revision'),
      operations: _decodePatchOperations(
        json['operations'],
        path: 'patch.operations',
      ),
    );
  }

  /// Encodes [envelope] into the supported native block patch JSON shape.
  Map<String, Object?> encodePatchEnvelope(
    TagflowNativeBlockPatchEnvelope envelope,
  ) {
    return {
      'id': envelope.documentId,
      'schemaVersion': envelope.schemaVersion,
      if (envelope.baseRevision != null) 'baseRevision': envelope.baseRevision,
      if (envelope.revision != null) 'revision': envelope.revision,
      'operations': [
        for (final operation in envelope.operations)
          _encodePatchOperation(operation),
      ],
    };
  }
}

/// Ordered native block patch envelope with producer revision tokens.
@immutable
final class TagflowNativeBlockPatchEnvelope {
  /// Creates a native block patch envelope.
  TagflowNativeBlockPatchEnvelope({
    required this.documentId,
    required this.schemaVersion,
    required List<TagflowNativeBlockPatch> operations,
    this.baseRevision,
    this.revision,
  }) : operations = List.unmodifiable(operations);

  /// Stable document identifier targeted by these operations.
  final String documentId;

  /// Adapter schema version for this patch payload.
  final int schemaVersion;

  /// Producer revision expected before applying these operations.
  final String? baseRevision;

  /// Producer revision after these operations are applied.
  final String? revision;

  /// Ordered native block patch operations.
  final List<TagflowNativeBlockPatch> operations;
}

List<TagflowNativeBlock> _decodeBlocks(Object? value, {required String path}) {
  if (value == null) {
    return const [];
  }
  if (value is! List<Object?>) {
    throw FormatException('$path must be a JSON array.');
  }

  return List.unmodifiable([
    for (var index = 0; index < value.length; index += 1)
      _decodeBlock(
        _requiredObject(value[index], path: '$path[$index]'),
        path: '$path[$index]',
      ),
  ]);
}

TagflowNativeBlock _decodeBlock(
  Map<String, Object?> json, {
  required String path,
}) {
  return TagflowNativeBlock(
    id: _requiredString(json, 'id', path: '$path.id'),
    kind: _nativeBlockKind(
      _requiredString(json, 'kind', path: '$path.kind'),
      path: '$path.kind',
    ),
    text: _optionalString(json, 'text', path: '$path.text'),
    attributes: _decodeJsonObject(json['attributes'], path: '$path.attributes'),
    children: _decodeBlocks(json['children'], path: '$path.children'),
    metadata: _decodeMetadata(json['metadata'], path: '$path.metadata'),
    source: _decodeSource(json['source'], path: '$path.source'),
  );
}

List<TagflowNativeBlockPatch> _decodePatchOperations(
  Object? value, {
  required String path,
}) {
  if (value == null) {
    return const [];
  }
  if (value is! List<Object?>) {
    throw FormatException('$path must be a JSON array.');
  }

  return List.unmodifiable([
    for (var index = 0; index < value.length; index += 1)
      _decodePatchOperation(
        _requiredObject(value[index], path: '$path[$index]'),
        path: '$path[$index]',
      ),
  ]);
}

TagflowNativeBlockPatch _decodePatchOperation(
  Map<String, Object?> json, {
  required String path,
}) {
  final op = _requiredString(json, 'op', path: '$path.op');
  return switch (op) {
    'replace' => TagflowNativeBlockPatch.replaceNode(
      nodeId: _requiredString(json, 'nodeId', path: '$path.nodeId'),
      block: _decodeBlock(
        _requiredObject(json['block'], path: '$path.block'),
        path: '$path.block',
      ),
    ),
    'append-children' => TagflowNativeBlockPatch.appendChildren(
      parentNodeId: _requiredString(
        json,
        'parentNodeId',
        path: '$path.parentNodeId',
      ),
      children: _decodeBlocks(json['blocks'], path: '$path.blocks'),
    ),
    'insert-before' => TagflowNativeBlockPatch.insertBefore(
      siblingNodeId: _requiredString(
        json,
        'siblingNodeId',
        path: '$path.siblingNodeId',
      ),
      nodes: _decodeBlocks(json['blocks'], path: '$path.blocks'),
    ),
    'remove' => TagflowNativeBlockPatch.removeNode(
      nodeId: _requiredString(json, 'nodeId', path: '$path.nodeId'),
    ),
    _ => throw FormatException('Unknown native block patch operation "$op".'),
  };
}

Map<String, Object?> _encodePatchOperation(TagflowNativeBlockPatch operation) {
  return switch (operation.kind) {
    TagflowNativeBlockPatchKind.replaceNode => {
      'op': 'replace',
      'nodeId': operation.targetNodeId,
      'block': const TagflowNativeBlockCodec().encodeBlock(operation.block!),
    },
    TagflowNativeBlockPatchKind.appendChildren => {
      'op': 'append-children',
      'parentNodeId': operation.targetNodeId,
      'blocks': [
        for (final block in operation.blocks)
          const TagflowNativeBlockCodec().encodeBlock(block),
      ],
    },
    TagflowNativeBlockPatchKind.insertBefore => {
      'op': 'insert-before',
      'siblingNodeId': operation.targetNodeId,
      'blocks': [
        for (final block in operation.blocks)
          const TagflowNativeBlockCodec().encodeBlock(block),
      ],
    },
    TagflowNativeBlockPatchKind.removeNode => {
      'op': 'remove',
      'nodeId': operation.targetNodeId,
    },
  };
}

TagflowNativeBlockKind _nativeBlockKind(String value, {required String path}) {
  for (final kind in TagflowNativeBlockKind.values) {
    if (kind.name == value) {
      return kind;
    }
  }
  throw FormatException('Unknown native block kind "$value" at $path.');
}

TagflowMetadata _decodeMetadata(Object? value, {required String path}) {
  if (value == null) {
    return TagflowMetadata.empty;
  }

  return TagflowMetadata(_decodeJsonObject(value, path: path));
}

Map<String, Object?> _encodeMetadata(TagflowMetadata metadata) {
  return _normalizeJsonObject(metadata.values, path: 'metadata');
}

TagflowSourceInfo? _decodeSource(Object? value, {required String path}) {
  if (value == null) {
    return null;
  }
  final json = _requiredObject(value, path: path);
  final uriValue = json['uri'];

  return TagflowSourceInfo(
    kind: _sourceKind(_requiredString(json, 'kind', path: '$path.kind')),
    adapter: _optionalString(json, 'adapter', path: '$path.adapter'),
    uri: uriValue == null
        ? null
        : Uri.parse(_stringValue(uriValue, path: '$path.uri')),
    line: _optionalInt(json, 'line', path: '$path.line'),
    column: _optionalInt(json, 'column', path: '$path.column'),
    metadata: _decodeMetadata(json['metadata'], path: '$path.metadata'),
  );
}

Map<String, Object?> _encodeSource(TagflowSourceInfo source) {
  return {
    'kind': source.kind.name,
    if (source.adapter != null) 'adapter': source.adapter,
    if (source.uri != null) 'uri': source.uri.toString(),
    if (source.line != null) 'line': source.line,
    if (source.column != null) 'column': source.column,
    if (!source.metadata.isEmpty) 'metadata': _encodeMetadata(source.metadata),
  };
}

TagflowSourceKind _sourceKind(String value) {
  for (final kind in TagflowSourceKind.values) {
    if (kind.name == value) {
      return kind;
    }
  }
  throw FormatException('Unknown native block source kind "$value".');
}

String _requiredString(
  Map<String, Object?> json,
  String key, {
  required String path,
}) {
  if (!json.containsKey(key)) {
    throw FormatException('$path is required.');
  }
  final value = _stringValue(json[key], path: path);
  if (value.trim().isEmpty) {
    throw FormatException('$path must not be blank.');
  }
  return value;
}

String? _optionalString(
  Map<String, Object?> json,
  String key, {
  required String path,
}) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  return _stringValue(json[key], path: path);
}

String _stringValue(Object? value, {required String path}) {
  if (value is String) {
    return value;
  }
  throw FormatException('$path must be a string.');
}

int _requiredPositiveInt(
  Map<String, Object?> json,
  String key, {
  required String path,
}) {
  if (!json.containsKey(key)) {
    throw FormatException('$path is required.');
  }
  final value = _intValue(json[key], path: path);
  if (value <= 0) {
    throw FormatException('$path must be greater than 0.');
  }
  return value;
}

int? _optionalInt(
  Map<String, Object?> json,
  String key, {
  required String path,
}) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  return _intValue(json[key], path: path);
}

int _intValue(Object? value, {required String path}) {
  if (value is int) {
    return value;
  }
  throw FormatException('$path must be an integer.');
}

Map<String, Object?> _requiredObject(Object? value, {required String path}) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return _normalizeJsonObject(value, path: path);
  }
  throw FormatException('$path must be a JSON object.');
}

Map<String, Object?> _decodeJsonObject(Object? value, {required String path}) {
  if (value == null) {
    return const {};
  }
  if (value is Map) {
    return _normalizeJsonObject(value, path: path);
  }
  throw FormatException('$path must be a JSON object.');
}

Map<String, Object?> _normalizeJsonObject(
  Map<dynamic, dynamic> value, {
  required String path,
}) {
  final normalized = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) {
      throw FormatException('$path must use string keys.');
    }
    normalized[key] = _normalizeJsonValue(entry.value, path: '$path.$key');
  }

  return Map.unmodifiable(normalized);
}

Object? _normalizeJsonValue(Object? value, {required String path}) {
  return switch (value) {
    null => null,
    bool() => value,
    String() => value,
    int() => value,
    double() when value.isFinite => value,
    double() => throw FormatException('$path must be a finite number.'),
    List() => List<Object?>.unmodifiable([
      for (var index = 0; index < value.length; index += 1)
        _normalizeJsonValue(value[index], path: '$path[$index]'),
    ]),
    Map() => _normalizeJsonObject(value, path: path),
    _ => throw FormatException('$path must contain only JSON-like data.'),
  };
}
