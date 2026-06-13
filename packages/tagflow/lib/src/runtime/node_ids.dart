/// Stable path-based ID helpers for runtime document nodes.
abstract final class TagflowNodeIds {
  /// The canonical root ID.
  static const String root = '0';

  /// Builds a stable path-based ID like `0.1.3`.
  static String fromPath(Iterable<int> path) {
    if (path.isEmpty) return root;
    return <String>[
      root,
      ...path.map((segment) => segment.toString()),
    ].join('.');
  }
}
