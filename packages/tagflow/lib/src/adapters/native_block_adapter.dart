import 'package:tagflow/src/adapters/native_block.dart';
import 'package:tagflow/src/runtime/runtime.dart';

const _nativeBlockAdapterName = 'native_block_v1';
const _nativeBlockKindKey = 'blockKind';
const _nativeBlockAttributesKey = 'blockAttributes';
const _nativeBlockSchemaVersionKey = 'schemaVersion';
const _nativeBlockRevisionKey = 'revision';
const _policyDecisionReasonKey = 'policyDecisionReason';

/// Adapts typed native blocks into the canonical [TagflowDocument] model.
final class TagflowNativeBlockAdapter {
  /// Creates a native block adapter.
  const TagflowNativeBlockAdapter({
    this.policy = TagflowContentPolicy.defaults,
    this.strictUnsupportedKinds = true,
  });

  /// Content policy applied to URL-bearing blocks.
  final TagflowContentPolicy policy;

  /// Whether unsupported block kinds throw instead of using policy fallback.
  final bool strictUnsupportedKinds;

  /// Converts [document] into the canonical runtime document model.
  TagflowDocument adapt(TagflowNativeBlockDocument document) {
    _validateDocument(document);
    final source = document.source ?? _defaultDocumentSource();

    return TagflowDocument(
      id: document.id,
      children: [
        for (final block in document.blocks)
          if (_adaptBlock(block, documentSource: source) case final node?) node,
      ],
      metadata: _documentMetadata(document),
      source: source,
    );
  }

  TagflowDocumentNode? _adaptBlock(
    TagflowNativeBlock block, {
    required TagflowSourceInfo documentSource,
  }) {
    final source = block.source ?? documentSource;
    final children = [
      for (final child in block.children)
        if (_adaptBlock(child, documentSource: documentSource)
            case final adaptedChild?)
          adaptedChild,
    ];
    final metadata = _metadataForBlock(block);

    return switch (block.kind) {
      TagflowNativeBlockKind.paragraph => TagflowDocumentNode.paragraph(
        id: block.id,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.heading => TagflowDocumentNode.heading(
        id: block.id,
        level: _requirePositiveInt(block, name: 'level'),
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.text => TagflowDocumentNode.text(
        id: block.id,
        text: block.text ?? '',
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.link => _adaptLinkBlock(
        block,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.list => TagflowDocumentNode.list(
        id: block.id,
        ordered: _boolAttribute(block, 'ordered') ?? false,
        startIndex: _intAttribute(block, 'startIndex'),
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.listItem => TagflowDocumentNode.listItem(
        id: block.id,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.blockquote => TagflowDocumentNode.blockquote(
        id: block.id,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.codeBlock => TagflowDocumentNode.codeBlock(
        id: block.id,
        text: block.text ?? '',
        language: _stringAttribute(block, 'language'),
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.inlineCode => TagflowDocumentNode.inlineCode(
        id: block.id,
        text: block.text ?? '',
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.image => _adaptImageBlock(
        block,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.table => TagflowDocumentNode.table(
        id: block.id,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.tableRow => TagflowDocumentNode.tableRow(
        id: block.id,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.tableCell => TagflowDocumentNode.tableCell(
        id: block.id,
        children: children,
        rowSpan: _positiveIntAttribute(block, 'rowSpan') ?? 1,
        colSpan: _positiveIntAttribute(block, 'colSpan') ?? 1,
        header: _boolAttribute(block, 'header') ?? false,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.callout => TagflowDocumentNode.container(
        id: block.id,
        children: children,
        metadata: metadata,
        presentation: _calloutPresentation(block),
        source: source,
      ),
      TagflowNativeBlockKind.container => TagflowDocumentNode.container(
        id: block.id,
        children: children,
        metadata: metadata,
        source: source,
      ),
      TagflowNativeBlockKind.horizontalRule =>
        TagflowDocumentNode.horizontalRule(
          id: block.id,
          metadata: metadata,
          source: source,
        ),
    };
  }

  TagflowDocumentNode _adaptLinkBlock(
    TagflowNativeBlock block, {
    required List<TagflowDocumentNode> children,
    required TagflowMetadata metadata,
    required TagflowSourceInfo source,
  }) {
    final urlDecision = policy.decideUrl(
      _requireString(block, name: 'url'),
      resourceType: TagflowResourceType.link,
    );
    if (!urlDecision.isAllowed) {
      return TagflowDocumentNode.container(
        id: block.id,
        children: children,
        metadata: _metadataForRejectedUrl(
          metadata,
          urlDecision.reason?.name ?? 'malformedUrl',
        ),
        source: source,
      );
    }

    return TagflowDocumentNode.link(
      id: block.id,
      url: urlDecision.uri!,
      children: children,
      metadata: metadata,
      source: source,
    );
  }

  TagflowDocumentNode? _adaptImageBlock(
    TagflowNativeBlock block, {
    required TagflowMetadata metadata,
    required TagflowSourceInfo source,
  }) {
    final urlDecision = policy.decideUrl(
      _requireString(block, name: 'url'),
      resourceType: TagflowResourceType.image,
    );
    if (!urlDecision.isAllowed) {
      return _policyRejectedNode(
        block,
        metadata: metadata,
        source: source,
        reason: urlDecision.reason?.name ?? 'malformedUrl',
      );
    }

    return TagflowDocumentNode.image(
      id: block.id,
      url: urlDecision.uri!,
      alt: _stringAttribute(block, 'alt'),
      width: _doubleAttribute(block, 'width'),
      height: _doubleAttribute(block, 'height'),
      metadata: metadata,
      source: source,
    );
  }

  TagflowDocumentNode? _policyRejectedNode(
    TagflowNativeBlock block, {
    required TagflowMetadata metadata,
    required TagflowSourceInfo source,
    required String reason,
  }) {
    if (policy.unsupportedBehavior == TagflowUnsupportedBehavior.drop) {
      return null;
    }

    return TagflowDocumentNode.unsupported(
      id: block.id,
      unsupportedReason:
          'Native block kind "${block.kind.name}" was rejected by policy.',
      metadata: _metadataForRejectedUrl(metadata, reason),
      source: source,
    );
  }

  void _validateDocument(TagflowNativeBlockDocument document) {
    _requireNonBlankId(document.id, label: 'document');
    if (document.schemaVersion <= 0) {
      throw ArgumentError.value(
        document.schemaVersion,
        'schemaVersion',
        'Native block schemaVersion must be greater than 0.',
      );
    }

    final seen = <String>{};

    void visit(TagflowNativeBlock block) {
      _requireNonBlankId(block.id, label: 'block');
      if (!seen.add(block.id)) {
        throw StateError('Duplicate TagflowNativeBlock id: ${block.id}.');
      }

      for (final child in block.children) {
        visit(child);
      }
    }

    for (final block in document.blocks) {
      visit(block);
    }
  }
}

TagflowSourceInfo _defaultDocumentSource() {
  return TagflowSourceInfo(
    kind: TagflowSourceKind.json,
    adapter: _nativeBlockAdapterName,
  );
}

TagflowMetadata _documentMetadata(TagflowNativeBlockDocument document) {
  return document.metadata.merge(
    TagflowMetadata({
      _nativeBlockSchemaVersionKey: document.schemaVersion,
      if (document.revision != null) _nativeBlockRevisionKey: document.revision,
    }),
  );
}

TagflowMetadata _metadataForBlock(TagflowNativeBlock block) {
  return block.metadata.merge(
    TagflowMetadata({
      _nativeBlockKindKey: block.kind.name,
      if (block.attributes.isNotEmpty)
        _nativeBlockAttributesKey: block.attributes,
    }),
  );
}

TagflowMetadata _metadataForRejectedUrl(
  TagflowMetadata metadata,
  String reason,
) {
  return metadata.merge(TagflowMetadata({_policyDecisionReasonKey: reason}));
}

TagflowPresentation? _calloutPresentation(TagflowNativeBlock block) {
  final variant = _stringAttribute(block, 'variant');
  final tone = _stringAttribute(block, 'tone');
  if (variant == null && tone == null) {
    return null;
  }

  return TagflowPresentation(
    variant: variant,
    hints: {if (tone != null) 'calloutTone': tone},
  );
}

void _requireNonBlankId(String id, {required String label}) {
  if (id.trim().isEmpty) {
    throw ArgumentError.value(
      id,
      label,
      'Native block $label id must not be blank.',
    );
  }
}

String _requireString(TagflowNativeBlock block, {required String name}) {
  final value = block.attributes[name];
  if (value is String && value.trim().isNotEmpty) {
    return value;
  }
  throw ArgumentError.value(
    value,
    name,
    'Native block "${block.id}" requires a non-empty "$name" attribute.',
  );
}

String? _stringAttribute(TagflowNativeBlock block, String name) {
  final value = block.attributes[name];
  return value is String ? value : null;
}

bool? _boolAttribute(TagflowNativeBlock block, String name) {
  final value = block.attributes[name];
  return value is bool ? value : null;
}

int? _intAttribute(TagflowNativeBlock block, String name) {
  final value = block.attributes[name];
  return switch (value) {
    int() => value,
    num() => value.toInt(),
    _ => null,
  };
}

int _requirePositiveInt(TagflowNativeBlock block, {required String name}) {
  final value = _intAttribute(block, name);
  if (value != null && value > 0) {
    return value;
  }
  throw ArgumentError.value(
    block.attributes[name],
    name,
    'Native block "${block.id}" requires a positive "$name" attribute.',
  );
}

int? _positiveIntAttribute(TagflowNativeBlock block, String name) {
  final value = _intAttribute(block, name);
  if (value == null || value <= 0) {
    return null;
  }
  return value;
}

double? _doubleAttribute(TagflowNativeBlock block, String name) {
  final value = block.attributes[name];
  return switch (value) {
    int() => value.toDouble(),
    num() => value.toDouble(),
    _ => null,
  };
}
