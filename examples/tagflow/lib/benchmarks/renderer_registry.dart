import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
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
    this.notes = const [],
  });

  /// Stable renderer id for tests and future benchmark result payloads.
  final String id;

  /// Human-readable label for the manual benchmark screen.
  final String label;

  /// Builds the benchmark widget.
  final BenchmarkRendererBuilder builder;

  /// Fairness caveats shown in the manual benchmark host and docs.
  final List<String> notes;
}

/// Default renderer used by manual and automated benchmark runs.
const String defaultBenchmarkRendererId = 'tagflow';

/// Stable renderer order for the benchmark picker UI.
const List<String> benchmarkRendererIds = [
  defaultBenchmarkRendererId,
  'flutter_html',
];

/// Benchmark renderers available to the example app harness.
final List<BenchmarkRenderer> benchmarkRendererList = [
  tagflowBenchmarkRenderer,
  flutterHtmlBenchmarkRenderer,
];

/// Renderer registry keyed by stable renderer id.
final Map<String, BenchmarkRenderer> benchmarkRenderers = {
  for (final renderer in benchmarkRendererList) renderer.id: renderer,
};

/// Resolves a benchmark renderer by id.
BenchmarkRenderer benchmarkRendererById(String id) {
  final renderer = benchmarkRenderers[id];
  if (renderer == null) {
    throw ArgumentError.value(id, 'id', 'Unknown benchmark renderer.');
  }

  return renderer;
}

/// Native Tagflow renderer for HTML fixture input.
const BenchmarkRenderer tagflowBenchmarkRenderer = BenchmarkRenderer(
  id: defaultBenchmarkRendererId,
  label: 'Tagflow',
  builder: _buildTagflowRenderer,
  notes: ['Renders the fixture through Tagflow with table converters enabled.'],
);

/// `flutter_html` adapter used for native HTML benchmark comparison.
const BenchmarkRenderer flutterHtmlBenchmarkRenderer = BenchmarkRenderer(
  id: 'flutter_html',
  label: 'Flutter HTML',
  builder: _buildFlutterHtmlRenderer,
  notes: [
    'Uses flutter_html with flutter_html_table for table support.',
    'Applies package-default styling instead of matching Tagflow theme rules.',
  ],
);

Widget _buildTagflowRenderer(BuildContext context, String html) {
  return Tagflow.html(
    html: html,
    converters: const [TagflowTableConverter(), TagflowTableCellConverter()],
    options: TagflowOptions(linkTapCallback: (_, _) {}),
  );
}

Widget _buildFlutterHtmlRenderer(BuildContext context, String html) {
  return Html(
    data: html,
    extensions: const [TableHtmlExtension()],
    onLinkTap: (_, _, _) {},
  );
}
