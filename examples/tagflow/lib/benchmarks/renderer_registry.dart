import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_table/tagflow_table.dart';

const _semanticBenchmarkHtmlAdapter = TagflowHtmlAdapter(
  nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
);

const _nativeBlockCodec = TagflowNativeBlockCodec();

const _nativeBlockAdapter = TagflowNativeBlockAdapter();

/// Builds a benchmark renderer for one fixture.
typedef BenchmarkRendererBuilder =
    Widget Function(BuildContext context, BenchmarkSourceDocument document);

/// Loaded benchmark input passed from the host into a renderer.
final class BenchmarkSourceDocument {
  /// Creates a loaded benchmark source.
  const BenchmarkSourceDocument({
    required this.type,
    required this.data,
    required this.assetPath,
    this.runtimeDocument,
  });

  /// Input format delivered to the renderer.
  final BenchmarkSourceType type;

  /// Raw fixture contents.
  final String data;

  /// Flutter asset path used to load the document.
  final String assetPath;

  /// Optional already-adapted Tagflow runtime document.
  final TagflowDocument? runtimeDocument;
}

/// Renderer available in the first profile benchmark scaffold.
final class BenchmarkRenderer {
  const BenchmarkRenderer({
    required this.id,
    required this.label,
    required this.builder,
    required this.supportedSourceTypes,
    this.notes = const [],
  });

  /// Stable renderer id for tests and future benchmark result payloads.
  final String id;

  /// Human-readable label for the manual benchmark screen.
  final String label;

  /// Builds the benchmark widget.
  final BenchmarkRendererBuilder builder;

  /// Source types accepted by this renderer.
  final Set<BenchmarkSourceType> supportedSourceTypes;

  /// Fairness caveats shown in the manual benchmark host and docs.
  final List<String> notes;

  /// Whether this renderer accepts the given fixture source type.
  bool supports(BenchmarkSourceType type) =>
      supportedSourceTypes.contains(type);

  /// Builds the benchmark widget for a validated source document.
  Widget build(BuildContext context, BenchmarkSourceDocument document) {
    if (!supports(document.type)) {
      throw StateError(
        'Renderer "$id" does not support ${document.type.name} fixtures. '
        'Tried to load ${document.assetPath}.',
      );
    }

    return builder(context, document);
  }
}

/// Default renderer used by manual and automated benchmark runs.
const String defaultBenchmarkRendererId = 'tagflow';

const String flutterWidgetFromHtmlCoreNote =
    'Uses flutter_widget_from_html_core because the shared alpha fixtures do '
    'not need the enhanced package audio, video, SVG, or webview mixins.';

/// Stable renderer order for the benchmark picker UI.
const List<String> benchmarkRendererIds = [
  defaultBenchmarkRendererId,
  'tagflow_semantic',
  semanticPatchBenchmarkRendererId,
  nativeJsonBenchmarkRendererId,
  'flutter_html',
  'flutter_widget_from_html',
  'flutter_markdown_plus',
  'markdown_widget',
];

/// Benchmark renderers available to the example app harness.
final List<BenchmarkRenderer> benchmarkRendererList = [
  tagflowBenchmarkRenderer,
  tagflowSemanticBenchmarkRenderer,
  tagflowSemanticPatchBenchmarkRenderer,
  tagflowNativeJsonBenchmarkRenderer,
  flutterHtmlBenchmarkRenderer,
  flutterWidgetFromHtmlBenchmarkRenderer,
  flutterMarkdownPlusBenchmarkRenderer,
  markdownWidgetBenchmarkRenderer,
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

/// Returns renderers compatible with the selected source type.
List<BenchmarkRenderer> benchmarkRenderersForSourceType(
  BenchmarkSourceType type,
) =>
    benchmarkRendererList.where((renderer) => renderer.supports(type)).toList();

const Set<String> _fixtureScopedRendererIds = {
  semanticPatchBenchmarkRendererId,
  nativeJsonBenchmarkRendererId,
};

/// Returns renderers compatible with the selected fixture.
List<BenchmarkRenderer> benchmarkRenderersForFixture(
  ProfileBenchmarkFixture fixture,
) => benchmarkRenderersForSourceType(fixture.source.type)
    .where((renderer) => benchmarkRendererSupportsFixture(renderer, fixture))
    .toList();

/// Whether [renderer] is compatible with [fixture].
bool benchmarkRendererSupportsFixture(
  BenchmarkRenderer renderer,
  ProfileBenchmarkFixture fixture,
) {
  if (!renderer.supports(fixture.source.type)) {
    return false;
  }

  if (fixture.rendererIds.isNotEmpty) {
    return fixture.supportsRendererId(renderer.id);
  }

  return !_fixtureScopedRendererIds.contains(renderer.id);
}

/// Native Tagflow renderer for HTML fixture input.
const BenchmarkRenderer tagflowBenchmarkRenderer = BenchmarkRenderer(
  id: defaultBenchmarkRendererId,
  label: 'Tagflow (compat)',
  builder: _buildTagflowRenderer,
  supportedSourceTypes: {BenchmarkSourceType.html},
  notes: ['Renders the fixture through Tagflow with table converters enabled.'],
);

/// Native Tagflow renderer using semantic document components.
const BenchmarkRenderer tagflowSemanticBenchmarkRenderer = BenchmarkRenderer(
  id: 'tagflow_semantic',
  label: 'Tagflow (semantic)',
  builder: _buildTagflowSemanticRenderer,
  supportedSourceTypes: {BenchmarkSourceType.html},
  notes: [
    'Parses HTML through TagflowHtmlAdapter, then renders TagflowDocument',
    'with the first-party semantic table registry extension.',
  ],
);

/// Native Tagflow renderer for the semantic document patch stream lane.
const BenchmarkRenderer tagflowSemanticPatchBenchmarkRenderer =
    BenchmarkRenderer(
      id: semanticPatchBenchmarkRendererId,
      label: 'Tagflow (semantic patch)',
      builder: _buildTagflowSemanticPatchRenderer,
      supportedSourceTypes: {BenchmarkSourceType.html},
      notes: [
        'Uses a pre-adapted TagflowDocument when supplied by the patch stream',
        'benchmark, then renders with the first-party semantic table registry',
        'extension.',
      ],
    );

/// Native Tagflow renderer for native block JSON fixture input.
const BenchmarkRenderer tagflowNativeJsonBenchmarkRenderer = BenchmarkRenderer(
  id: nativeJsonBenchmarkRendererId,
  label: 'Tagflow (native JSON)',
  builder: _buildTagflowNativeJsonRenderer,
  supportedSourceTypes: {BenchmarkSourceType.nativeJson},
  notes: [
    'Decodes native block JSON into TagflowDocument before rendering.',
    'Keeps profile rendering separate from native transport microbenchmarks.',
  ],
);

/// `flutter_html` adapter used for native HTML benchmark comparison.
const BenchmarkRenderer flutterHtmlBenchmarkRenderer = BenchmarkRenderer(
  id: 'flutter_html',
  label: 'Flutter HTML',
  builder: _buildFlutterHtmlRenderer,
  supportedSourceTypes: {BenchmarkSourceType.html},
  notes: [
    'Uses flutter_html with flutter_html_table for table support.',
    'Applies package-default styling instead of matching Tagflow theme rules.',
  ],
);

/// `flutter_widget_from_html` adapter used for native HTML comparison.
const BenchmarkRenderer
flutterWidgetFromHtmlBenchmarkRenderer = BenchmarkRenderer(
  id: 'flutter_widget_from_html',
  label: 'Flutter Widget from HTML (core)',
  builder: _buildFlutterWidgetFromHtmlRenderer,
  supportedSourceTypes: {BenchmarkSourceType.html},
  notes: [
    flutterWidgetFromHtmlCoreNote,
    'Applies package-default styling instead of matching Tagflow theme rules.',
  ],
);

/// `flutter_markdown_plus` adapter used for markdown-native comparison.
const BenchmarkRenderer flutterMarkdownPlusBenchmarkRenderer =
    BenchmarkRenderer(
      id: 'flutter_markdown_plus',
      label: 'Flutter Markdown Plus',
      builder: _buildFlutterMarkdownPlusRenderer,
      supportedSourceTypes: {BenchmarkSourceType.markdown},
      notes: [
        'Uses flutter_markdown_plus with package-default styling.',
        'Uses MarkdownBody to avoid nesting a second scroll view inside the',
        'benchmark host.',
      ],
    );

/// `markdown_widget` adapter used for markdown-native comparison.
const BenchmarkRenderer markdownWidgetBenchmarkRenderer = BenchmarkRenderer(
  id: 'markdown_widget',
  label: 'Markdown Widget',
  builder: _buildMarkdownWidgetRenderer,
  supportedSourceTypes: {BenchmarkSourceType.markdown},
  notes: [
    'Uses markdown_widget with package-default styling.',
    'Uses MarkdownBlock inside the shared benchmark host scroll surface.',
  ],
);

Widget _buildTagflowRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  return Tagflow.html(
    html: document.data,
    converters: const [TagflowTableConverter(), TagflowTableCellConverter()],
    options: TagflowOptions(linkTapCallback: (_, _) {}),
  );
}

Widget _buildTagflowSemanticRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  final runtimeDocument = _semanticBenchmarkHtmlAdapter.parse(document.data);
  return Tagflow.document(
    runtimeDocument,
    registry: TagflowComponentRegistry(extensions: [tagflowTableComponents()]),
    options: TagflowOptions(linkTapCallback: (_, _) {}),
  );
}

Widget _buildTagflowSemanticPatchRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  final runtimeDocument =
      document.runtimeDocument ??
      _semanticBenchmarkHtmlAdapter.parse(document.data);
  return Tagflow.document(
    runtimeDocument,
    registry: TagflowComponentRegistry(extensions: [tagflowTableComponents()]),
    options: TagflowOptions(linkTapCallback: (_, _) {}),
  );
}

Widget _buildTagflowNativeJsonRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  final nativeDocument = _nativeBlockCodec.decodeDocument(
    _decodeJsonObject(document.data),
  );
  final runtimeDocument = _nativeBlockAdapter.adapt(nativeDocument);

  return Tagflow.document(
    runtimeDocument,
    registry: TagflowComponentRegistry(extensions: [tagflowTableComponents()]),
    options: TagflowOptions(linkTapCallback: (_, _) {}),
  );
}

Widget _buildFlutterHtmlRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  return Html(
    data: document.data,
    extensions: const [TableHtmlExtension()],
    onLinkTap: (_, _, _) {},
  );
}

Widget _buildFlutterWidgetFromHtmlRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  return HtmlWidget(document.data);
}

Widget _buildFlutterMarkdownPlusRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  return MarkdownBody(data: document.data, selectable: true);
}

Widget _buildMarkdownWidgetRenderer(
  BuildContext context,
  BenchmarkSourceDocument document,
) {
  return MarkdownBlock(data: document.data);
}

Map<String, Object?> _decodeJsonObject(String data) {
  final decoded = jsonDecode(data);
  final normalized = _normalizeJsonValue(decoded);
  if (normalized is Map<String, Object?>) {
    return normalized;
  }
  throw const FormatException('Native JSON fixture must be a JSON object.');
}

Object? _normalizeJsonValue(Object? value) {
  if (value is Map) {
    final result = <String, Object?>{};
    for (final entry in value.entries) {
      final key = entry.key;
      if (key is! String) {
        throw const FormatException('Native JSON object keys must be strings.');
      }
      result[key] = _normalizeJsonValue(entry.value);
    }
    return result;
  }
  if (value is List) {
    return <Object?>[for (final item in value) _normalizeJsonValue(item)];
  }
  return value;
}
