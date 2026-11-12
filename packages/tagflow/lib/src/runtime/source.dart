import 'package:meta/meta.dart';
import 'package:tagflow/src/runtime/metadata.dart';

/// High-level source kinds that can produce a Tagflow document.
enum TagflowSourceKind {
  /// HTML input.
  html,

  /// Markdown input.
  markdown,

  /// Native block JSON.
  json,

  /// A document built in app code.
  app,

  /// A source that is not known.
  unknown,
}

/// Source location and adapter metadata for a document or node.
@immutable
final class TagflowSourceInfo {
  /// Creates a new source info record.
  TagflowSourceInfo({
    required this.kind,
    this.adapter,
    this.uri,
    this.line,
    this.column,
    TagflowMetadata? metadata,
  }) : metadata = metadata ?? TagflowMetadata.empty;

  /// Source kind.
  final TagflowSourceKind kind;

  /// Adapter name, such as `html`.
  final String? adapter;

  /// Optional source URI.
  final Uri? uri;

  /// Optional 1-based line number.
  final int? line;

  /// Optional 1-based column number.
  final int? column;

  /// Additional source metadata.
  final TagflowMetadata metadata;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowSourceInfo &&
            other.kind == kind &&
            other.adapter == adapter &&
            other.uri == uri &&
            other.line == line &&
            other.column == column &&
            other.metadata == metadata;
  }

  @override
  int get hashCode => Object.hash(kind, adapter, uri, line, column, metadata);
}
