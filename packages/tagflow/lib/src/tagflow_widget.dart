import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/src/adapters/html_adapter.dart';
import 'package:tagflow/src/converter/converter.dart';
import 'package:tagflow/src/core/models/models.dart';
import 'package:tagflow/src/render/render.dart';
import 'package:tagflow/src/runtime/runtime.dart';
import 'package:tagflow/src/style/theme.dart';
import 'package:tagflow/src/tagflow_options.dart';

/// Legacy widget-level error builder typedef.
typedef ErrorWidgetBuilder = TagflowErrorWidgetBuilder;

/// Default error widget builder
Widget _defaultErrorWidget(BuildContext context, Object? error) {
  return SelectableText(
    'Failed to render content: $error',
    style: const TextStyle(color: Color(0xFFB00020)),
  );
}

/// Default loading widget builder
Widget _defaultLoadingWidget(BuildContext context) {
  return const Center(child: CircularProgressIndicator());
}

/// Main widget for rendering rich content.
class Tagflow extends StatefulWidget {
  /// Creates a new legacy HTML [Tagflow] widget.
  const Tagflow({
    required String this.html,
    this.theme,
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    TagflowOptions? options,
    TagflowRenderBoundary? renderBoundary,
    super.key,
  }) : assert(
         viewOptions == null || options == null,
         'Pass either viewOptions or options, not both.',
       ),
       _viewOptions = viewOptions,
       _legacyOptions = options,
       _renderBoundary = renderBoundary,
       document = null,
       adapter = null,
       registry = null;

  /// Creates a new [Tagflow] widget from HTML.
  const Tagflow.html({
    required String this.html,
    this.adapter,
    this.theme,
    this.registry,
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    TagflowOptions? options,
    TagflowRenderBoundary? renderBoundary,
    super.key,
  }) : assert(
         viewOptions == null || options == null,
         'Pass either viewOptions or options, not both.',
       ),
       _viewOptions = viewOptions,
       _legacyOptions = options,
       _renderBoundary = renderBoundary,
       document = null;

  /// Creates a new [Tagflow] widget from a native runtime document.
  const Tagflow.document(
    TagflowDocument this.document, {
    this.theme,
    this.registry,
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    TagflowOptions? options,
    super.key,
  }) : assert(
         viewOptions == null || options == null,
         'Pass either viewOptions or options, not both.',
       ),
       _viewOptions = viewOptions,
       _legacyOptions = options,
       _renderBoundary = null,
       html = null,
       adapter = null;

  /// The HTML content to render.
  final String? html;

  /// The canonical runtime document to render.
  final TagflowDocument? document;

  /// Adapter used by [Tagflow.html] to produce a runtime document.
  final TagflowHtmlAdapter? adapter;

  /// Custom theme for styling HTML elements
  final TagflowTheme? theme;

  /// Semantic component registry used by [Tagflow.document] and [Tagflow.html].
  final TagflowComponentRegistry? registry;

  /// Additional converters to use
  final List<ElementConverter> converters;

  /// Error builder for handling parsing/conversion errors
  final ErrorWidgetBuilder errorBuilder;

  /// Loading widget shown while parsing
  final WidgetBuilder loadingBuilder;

  final TagflowViewOptions? _viewOptions;
  final TagflowOptions? _legacyOptions;
  final TagflowRenderBoundary? _renderBoundary;

  /// Runtime view options for configuring the Tagflow widget.
  TagflowViewOptions get viewOptions =>
      _viewOptions ??
      _legacyOptions?.toViewOptions() ??
      TagflowViewOptions.defaults;

  /// HTML-only render boundary used by HTML entry points.
  TagflowRenderBoundary? get renderBoundary =>
      _renderBoundary ?? _legacyOptions?.renderBoundary;

  /// Legacy compatibility access to the old options shape.
  TagflowOptions get options =>
      _legacyOptions ??
      TagflowOptions.fromViewOptions(
        viewOptions,
        renderBoundary: _renderBoundary,
      );

  @override
  State<Tagflow> createState() => _TagflowState();
}

class _TagflowState extends State<Tagflow> {
  late TagflowConverter _converter;
  TagflowDocument? _document;
  TagflowNode? _element;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _converter = TagflowConverter(widget.converters);
    _loadDocument();
  }

  @override
  void didUpdateWidget(Tagflow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final convertersChanged = !listEquals(
      oldWidget.converters,
      widget.converters,
    );
    if (convertersChanged) {
      _converter = TagflowConverter(widget.converters);
    }

    if (oldWidget.html != widget.html ||
        oldWidget.document != widget.document ||
        oldWidget.adapter != widget.adapter ||
        oldWidget.viewOptions != widget.viewOptions ||
        oldWidget.renderBoundary != widget.renderBoundary ||
        (convertersChanged && widget.document == null)) {
      _loadDocument();
      return;
    }

    if (oldWidget.registry != widget.registry &&
        !_usesLegacyCompatibilityRenderer) {
      setState(() {});
    }
  }

  void _loadDocument() {
    try {
      _document =
          widget.document ??
          (widget.adapter ?? const TagflowHtmlAdapter()).parse(
            widget.html ?? '',
            viewOptions: widget.viewOptions,
            renderBoundary: widget.renderBoundary,
          );
      _element = _usesLegacyCompatibilityRenderer
          ? TagflowHtmlDocumentBridge.toLegacyNode(_document!)
          : null;
      _error = null;
    } catch (e, stack) {
      _error = e;
      if (widget.viewOptions.debug) {
        debugPrint('Error loading Tagflow document: $e\n$stack');
      }
    }
    if (mounted) setState(() {});
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return (widget.viewOptions.errorBuilder ?? widget.errorBuilder)(
        context,
        _error,
      );
    }

    if (_document == null) {
      return widget.loadingBuilder(context);
    }

    Widget content;
    if (_usesLegacyCompatibilityRenderer) {
      if (_element == null) return widget.loadingBuilder(context);
      content = _converter.convert(_element!, context);
    } else {
      content = (widget.registry ?? TagflowComponentRegistry.builtIn).render(
        context,
        TagflowDocumentNode.root(
          id: '${_document!.id}:root',
          children: _document!.children,
        ),
      );
    }

    return widget.viewOptions.selectable.enabled
        ? SelectionArea(child: content)
        : content;
  }

  bool get _usesLegacyCompatibilityRenderer =>
      widget.document == null && widget.converters.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return TagflowScope.view(
      viewOptions: widget.viewOptions,
      child: widget.theme != null
          ? TagflowThemeProvider.merge(
              context,
              theme: widget.theme!,
              child: Builder(builder: _buildContent),
            )
          : Builder(builder: _buildContent),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('html', widget.html))
      ..add(DiagnosticsProperty<TagflowDocument>('document', _document))
      ..add(DiagnosticsProperty<TagflowHtmlAdapter>('adapter', widget.adapter))
      ..add(DiagnosticsProperty<TagflowTheme>('theme', widget.theme))
      ..add(
        DiagnosticsProperty<TagflowComponentRegistry>(
          'registry',
          widget.registry,
        ),
      )
      ..add(IterableProperty<ElementConverter>('converters', widget.converters))
      ..add(
        DiagnosticsProperty<TagflowViewOptions>(
          'viewOptions',
          widget.viewOptions,
        ),
      )
      ..add(
        DiagnosticsProperty<TagflowRenderBoundary>(
          'renderBoundary',
          widget.renderBoundary,
        ),
      )
      ..add(DiagnosticsProperty<TagflowNode>('element', _element))
      ..add(DiagnosticsProperty<Object>('error', _error));
  }
}
