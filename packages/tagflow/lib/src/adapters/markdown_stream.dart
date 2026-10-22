import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tagflow/src/adapters/markdown_adapter.dart';
import 'package:tagflow/src/runtime/runtime.dart';

/// Default document id used by [TagflowMarkdownStream].
const _defaultStreamDocumentId = 'markdown-stream';

/// How many split points one update tries before giving up on committing.
const _maxCommitAttempts = 3;

final _blankLine = RegExp(r'^\s*$');
final _fenceOpen = RegExp('^ {0,3}(`{3,}|~{3,})');
final _pipeRow = RegExp(r'^ {0,3}\|');
final _delimiterRow = RegExp(r'^ {0,3}[|:\- \t]+\r?$');

// A trailing line that may still turn into block structure (list marker,
// heading marker, setext underline, thematic break, blockquote or fence) once
// more text arrives. Showing it early would flash a paragraph that changes
// kind on the next chunk.
final _structuralPrefix = RegExp(
  r'^ {0,3}(?:[-+*=_#>~`:| \t]*|\d{1,9}[.)]?[ \t]*|(?:`{3,}|~{3,})[^`]*)$',
);
final _fenceCharsOnly = RegExp(r'^ {0,3}(?:`+|~+)[ \t]*$');

/// One update emitted by [TagflowMarkdownStream.updates].
@immutable
final class TagflowMarkdownStreamUpdate {
  /// Creates a stream update.
  const TagflowMarkdownStreamUpdate({
    required this.document,
    required this.patches,
    required this.isClosed,
  });

  /// The document after [patches] were applied.
  final TagflowDocument document;

  /// Patches that turn the previous document into [document].
  ///
  /// Top-level nodes that did not change are not patched and keep their
  /// identity.
  final List<TagflowDocumentPatch> patches;

  /// Whether the stream was closed by this update.
  final bool isClosed;
}

/// Builds a [TagflowDocument] incrementally from Markdown that arrives in
/// chunks, such as an AI answer streamed token by token.
///
/// Append text with [add] (or [addStream]) and call [close] when the source
/// is done. [document] always holds the current document, listeners are
/// notified on every change, and [updates] carries the
/// [TagflowDocumentPatch]es between documents.
///
/// Only the open tail of the text is re-parsed. A top-level block is closed
/// once the text after it starts a new block that cannot merge back into it;
/// closed blocks keep their node ids and node instances and are never parsed
/// again. While the stream is open, a trailing line that may still become
/// block structure (a fence, list marker, heading marker or table header
/// waiting for its delimiter row) is held back until it is complete, so
/// output does not flash between kinds.
///
/// [close] parses the full text once, so the final document matches
/// [TagflowMarkdownAdapter.parse] with the same `id`, even for constructs
/// that reach across blocks, such as link reference definitions and
/// footnotes.
final class TagflowMarkdownStream extends ChangeNotifier {
  /// Creates an empty Markdown stream.
  TagflowMarkdownStream({
    this.adapter = const TagflowMarkdownAdapter(),
    String id = _defaultStreamDocumentId,
    Uri? uri,
    TagflowMetadata? metadata,
  }) : _uri = uri,
       _metadata = metadata,
       _document = adapter.parse('', id: id, uri: uri, metadata: metadata);

  /// Adapter used to parse the text.
  final TagflowMarkdownAdapter adapter;

  final Uri? _uri;
  final TagflowMetadata? _metadata;
  final StreamController<TagflowMarkdownStreamUpdate> _updates =
      StreamController.broadcast();

  final StringBuffer _committedText = StringBuffer();
  String _tail = '';
  List<TagflowDocumentNode> _committedNodes = const [];
  int _committedBlockCount = 0;
  TagflowDocument _document;
  bool _closed = false;
  bool _disposed = false;

  /// The current document.
  TagflowDocument get document => _document;

  /// All text added so far.
  String get text => '$_committedText$_tail';

  /// Whether [close] was called.
  bool get isClosed => _closed;

  /// Patches and documents, one event per change.
  Stream<TagflowMarkdownStreamUpdate> get updates => _updates.stream;

  /// Appends [chunk] and updates [document].
  ///
  /// Throws [StateError] after [close].
  void add(String chunk) {
    if (_closed) {
      throw StateError('Cannot add Markdown to a closed stream.');
    }
    if (chunk.isEmpty) return;
    _tail += chunk;
    _update();
  }

  /// Adds every chunk of [chunks], then calls [close] when [closeOnDone] is
  /// true.
  ///
  /// The returned future completes when [chunks] is done, and with an error
  /// when [chunks] reports one.
  Future<void> addStream(
    Stream<String> chunks, {
    bool closeOnDone = true,
  }) async {
    await for (final chunk in chunks) {
      if (_disposed) return;
      add(chunk);
    }
    if (closeOnDone && !_disposed) close();
  }

  /// Marks the text as complete and publishes the final document.
  ///
  /// Calling [close] more than once has no effect.
  void close() {
    if (_closed) return;
    _closed = true;
    final complete = adapter.parse(
      text,
      id: _document.id,
      uri: _uri,
      metadata: _metadata,
    );
    _publish(complete.children, force: true);
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_updates.close());
    super.dispose();
  }

  void _update() {
    final visible = _stableText(_tail);
    final blocks = _parse(visible, _committedBlockCount);
    final committedNodeCount = _committedNodes.length;
    final children = [..._committedNodes, ...blocks.nonNulls];

    var newlyCommitted = 0;
    for (final split in _splitPoints(visible).take(_maxCommitAttempts)) {
      final head = _parse(visible.substring(0, split), _committedBlockCount);
      if (head.isEmpty) continue;
      final rest = _parse(
        visible.substring(split),
        _committedBlockCount + head.length,
      );
      if (!listEquals([...head, ...rest], blocks)) continue;

      _committedText.write(_tail.substring(0, split));
      _tail = _tail.substring(split);
      _committedBlockCount += head.length;
      newlyCommitted = head.nonNulls.length;
      break;
    }

    _publish(children);
    if (newlyCommitted > 0) {
      _committedNodes = List.unmodifiable(
        _document.children.take(committedNodeCount + newlyCommitted),
      );
    }
  }

  List<TagflowDocumentNode?> _parse(String markdown, int firstBlockIndex) {
    return tagflowAdaptMarkdownBlocks(
      adapter,
      markdown,
      firstBlockIndex: firstBlockIndex,
      uri: _uri,
    );
  }

  void _publish(List<TagflowDocumentNode> children, {bool force = false}) {
    final patches = _diff(_document.children, children);
    if (patches.isEmpty && !force) return;

    _document = _document.applyPatches(patches);
    if (_disposed) return;
    _updates.add(
      TagflowMarkdownStreamUpdate(
        document: _document,
        patches: List.unmodifiable(patches),
        isClosed: _closed,
      ),
    );
    notifyListeners();
  }
}

/// Top-level patches from [previous] to [next].
///
/// Both lists hold path-based ids in document order, so surviving nodes keep
/// their relative order and new nodes are inserted before the next surviving
/// node or appended at the end.
List<TagflowDocumentPatch> _diff(
  List<TagflowDocumentNode> previous,
  List<TagflowDocumentNode> next,
) {
  final previousById = {for (final node in previous) node.id: node};
  final nextIds = {for (final node in next) node.id};
  final patches = <TagflowDocumentPatch>[
    for (final node in previous)
      if (!nextIds.contains(node.id))
        TagflowDocumentPatch.removeNode(nodeId: node.id),
  ];

  var pending = <TagflowDocumentNode>[];
  for (final node in next) {
    final old = previousById[node.id];
    if (old == null) {
      pending.add(node);
      continue;
    }
    if (pending.isNotEmpty) {
      patches.add(
        TagflowDocumentPatch.insertBefore(
          siblingNodeId: node.id,
          nodes: pending,
        ),
      );
      pending = [];
    }
    if (old != node) {
      patches.add(
        TagflowDocumentPatch.replaceNode(nodeId: node.id, node: node),
      );
    }
  }
  if (pending.isNotEmpty) {
    patches.add(TagflowDocumentPatch.appendRootChildren(children: pending));
  }
  return patches;
}

/// The part of an open stream's [text] that is safe to render now.
///
/// Holds back a trailing line that may still become block structure, and a
/// table header row whose delimiter row has not arrived yet.
String _stableText(String text) {
  final lastNewline = text.lastIndexOf('\n');
  final complete = text.substring(0, lastNewline + 1);
  final partial = text.substring(lastNewline + 1);
  final lines = complete.split('\n')..removeLast();
  final inFence = _endsInsideFence(lines);

  if (partial.isEmpty) {
    // Fall through to the table header check below.
  } else if (inFence) {
    if (!_fenceCharsOnly.hasMatch(partial)) return text;
    return complete;
  } else if (!_isUnstableLine(partial, lines.lastOrNull)) {
    return text;
  }
  if (inFence || lines.isEmpty) return complete;

  // A pipe row that starts a block is a potential table header. Until the
  // delimiter row is complete it would render as a paragraph.
  final last = lines.last;
  final beforeLast = lines.length > 1 ? lines[lines.length - 2] : null;
  if (_pipeRow.hasMatch(last) &&
      (beforeLast == null || !_pipeRow.hasMatch(beforeLast))) {
    return complete.substring(0, complete.length - last.length - 1);
  }
  return complete;
}

bool _isUnstableLine(String partial, String? previousLine) {
  if (_pipeRow.hasMatch(partial)) {
    // A partial body row renders fine. A potential header or delimiter row
    // does not.
    final previousIsRow =
        previousLine != null && _pipeRow.hasMatch(previousLine);
    return !previousIsRow || _delimiterRow.hasMatch(partial);
  }
  return _structuralPrefix.hasMatch(partial);
}

bool _endsInsideFence(List<String> lines) {
  String? fence;
  for (final line in lines) {
    fence = _nextFence(fence, line);
  }
  return fence != null;
}

/// Tracks fenced code blocks line by line: returns the open fence marker
/// after [line], or `null` outside a fence.
String? _nextFence(String? fence, String line) {
  if (fence == null) {
    return _fenceOpen.firstMatch(line)?.group(1);
  }
  final trimmed = line.trim();
  final closes =
      trimmed.length >= fence.length &&
      trimmed.split('').every((char) => char == fence[0]);
  return closes ? null : fence;
}

/// Candidate offsets in [text] where a closed block may end, latest first.
///
/// A candidate is the start of a complete, non-blank line that follows a
/// blank line outside a fenced code block. Callers still verify that
/// splitting there parses the same as the whole text.
List<int> _splitPoints(String text) {
  final candidates = <int>[];
  String? fence;
  var offset = 0;
  var previousBlank = false;
  while (true) {
    final end = text.indexOf('\n', offset);
    // Only complete lines count, so a block start is never judged on half a
    // line.
    if (end < 0) break;
    final line = text.substring(offset, end);
    final blank = fence == null && _blankLine.hasMatch(line);
    if (fence == null && !blank && previousBlank && offset > 0) {
      candidates.add(offset);
    }
    fence = _nextFence(fence, line);
    previousBlank = blank;
    offset = end + 1;
  }
  return candidates.reversed.toList(growable: false);
}
