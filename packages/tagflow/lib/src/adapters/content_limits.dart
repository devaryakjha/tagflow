import 'package:tagflow/src/runtime/runtime.dart';

const _policyDecisionReasonKey = 'policyDecisionReason';

/// Tag of the element that replaces content nested deeper than
/// `TagflowParser.maxDepth`.
const tagflowLimitDepthTag = 'tagflow-limit-depth';

/// Tag of the element that marks content cut after `TagflowParser.maxNodes`.
const tagflowLimitNodesTag = 'tagflow-limit-nodes';

/// Largest `colspan` the HTML specification allows.
const maxTableColSpan = 1000;

/// Largest `rowspan` the HTML specification allows.
const maxTableRowSpan = 65534;

/// Most grid columns a table lays out; matches [maxTableColSpan].
const maxTableColumns = 1000;

/// Parses a span attribute and clamps it to `1..max`, as the HTML
/// specification clamps `colspan` and `rowspan`.
///
/// The specification treats `rowspan="0"` as "to the end of the row group";
/// Tagflow treats it as 1 like any other out-of-range value.
int clampTableSpan(String? raw, int max) {
  final value = int.tryParse(raw?.trim() ?? '') ?? 1;
  if (value < 1) return 1;
  return value > max ? max : value;
}

/// The node that stands in for content cut off by [limit], or `null` when
/// [policy] drops unsupported content.
TagflowDocumentNode? tagflowContentLimitNode(
  TagflowContentPolicy policy,
  TagflowContentLimit limit, {
  required String id,
  TagflowSourceInfo? source,
  TagflowMetadata? metadata,
}) {
  if (policy.unsupportedBehavior == TagflowUnsupportedBehavior.drop) {
    return null;
  }

  return TagflowDocumentNode.unsupported(
    id: id,
    unsupportedReason: switch (limit) {
      TagflowContentLimit.maxDepth =>
        'Content nested deeper than the policy maxDepth '
            '(${policy.maxDepth}) was cut off.',
      TagflowContentLimit.maxNodes =>
        'Content after the policy maxNodes (${policy.maxNodes}) was cut off.',
    },
    metadata: (metadata ?? TagflowMetadata.empty).merge(
      TagflowMetadata({_policyDecisionReasonKey: limit.name}),
    ),
    presentation: TagflowPresentation(variant: 'unsupported'),
    source: source,
  );
}

/// Tracks [TagflowContentPolicy.maxDepth] and [TagflowContentPolicy.maxNodes]
/// while an adapter walks a tree.
final class TagflowContentBudget {
  /// Creates a budget for one adaptation pass under [policy].
  TagflowContentBudget(this.policy);

  /// Policy whose limits are tracked.
  final TagflowContentPolicy policy;

  int _nodes = 0;
  bool _markedNodeLimit = false;

  /// Counts a node at [depth] (top-level nodes are depth 1).
  ///
  /// Returns `null` when the node may be adapted, or the limit it hit. A node
  /// that hits a limit must be replaced by [cutOff] and its subtree skipped.
  TagflowContentLimit? admit(int depth) {
    if (_nodes >= policy.maxNodes) return TagflowContentLimit.maxNodes;
    _nodes++;
    if (depth > policy.maxDepth) return TagflowContentLimit.maxDepth;
    return null;
  }

  /// The node that replaces content cut off by [limit], or `null`.
  ///
  /// Only the first node cut by [TagflowContentLimit.maxNodes] gets a
  /// placeholder, so a long tail of cut content leaves one marker.
  TagflowDocumentNode? cutOff(
    TagflowContentLimit limit, {
    required String id,
    TagflowSourceInfo? source,
    TagflowMetadata? metadata,
  }) {
    if (limit == TagflowContentLimit.maxNodes) {
      if (_markedNodeLimit) return null;
      _markedNodeLimit = true;
    }
    return tagflowContentLimitNode(
      policy,
      limit,
      id: id,
      source: source,
      metadata: metadata,
    );
  }
}
