import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

/// Builds a benchmark renderer for one fixture.
typedef BenchmarkRendererBuilder =
    Widget Function(BuildContext context, String html);

/// Renderer available in the first profile benchmark scaffold.
final class BenchmarkRenderer {
  const BenchmarkRenderer({
    required this.id,
    required this.label,
    required this.builder,
  });

  /// Stable renderer id for tests and future benchmark result payloads.
  final String id;

  /// Human-readable label for the manual benchmark screen.
  final String label;

  /// Builds the benchmark widget.
  final BenchmarkRendererBuilder builder;
}

/// Tagflow-only renderer registry for the initial profile benchmark route.
final Map<String, BenchmarkRenderer> benchmarkRenderers = {
  tagflowBenchmarkRenderer.id: tagflowBenchmarkRenderer,
};

/// Native Tagflow renderer for HTML fixture input.
const BenchmarkRenderer tagflowBenchmarkRenderer = BenchmarkRenderer(
  id: 'tagflow',
  label: 'Tagflow',
  builder: _buildTagflowRenderer,
);

Widget _buildTagflowRenderer(BuildContext context, String html) {
  return Tagflow.html(
    html: html,
    converters: const [TagflowTableConverter(), TagflowTableCellConverter()],
    options: TagflowOptions(linkTapCallback: (_, _) {}),
  );
}
