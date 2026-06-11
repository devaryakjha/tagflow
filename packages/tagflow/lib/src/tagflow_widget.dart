import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Error widget builder for handling parsing/conversion errors
typedef ErrorWidgetBuilder =
    Widget Function(BuildContext context, Object? error);

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
    this.options = TagflowOptions.defaults,
    super.key,
  }) : document = null,
       adapter = null,
       registry = null;

  /// Creates a new [Tagflow] widget from HTML.
  const Tagflow.html({
    required String this.html,
    this.adapter,
    this.theme,
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    this.options = TagflowOptions.defaults,
    super.key,
  }) : document = null,
       registry = null;

  /// Creates a new [Tagflow] widget from a native runtime document.
  const Tagflow.document(
    TagflowDocument this.document, {
    this.theme,
    this.registry,
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    this.options = TagflowOptions.defaults,
    super.key,
  }) : html = null,
       adapter = null;

  /// The HTML content to render.
  final String? html;

  /// The canonical runtime document to render.
  final TagflowDocument? document;

  /// Adapter used by [Tagflow.html] to produce a runtime document.
  final TagflowHtmlAdapter? adapter;

  /// Custom theme for styling HTML elements
  final TagflowTheme? theme;

  /// Semantic component registry used by [Tagflow.document].
  final TagflowComponentRegistry? registry;

  /// Additional converters to use
  final List<ElementConverter> converters;

  /// Error builder for handling parsing/conversion errors
  final ErrorWidgetBuilder errorBuilder;

  /// Loading widget shown while parsing
  final WidgetBuilder loadingBuilder;

  /// Options for configuring the Tagflow widget
  final TagflowOptions options;

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

    if (oldWidget.html != widget.html ||
        oldWidget.document != widget.document ||
        oldWidget.adapter != widget.adapter ||
        oldWidget.options.renderBoundary != widget.options.renderBoundary) {
      _loadDocument();
    }

    if (!listEquals(oldWidget.converters, widget.converters)) {
      _converter = TagflowConverter(widget.converters);
      if (_element != null) setState(() {});
    }

    if (oldWidget.registry != widget.registry && widget.document != null) {
      setState(() {});
    }
  }

  void _loadDocument() {
    try {
      _document =
          widget.document ??
          (widget.adapter ?? const TagflowHtmlAdapter()).parse(
            widget.html ?? '',
            options: widget.options,
          );
      _element = widget.document == null
          ? TagflowHtmlDocumentBridge.toLegacyNode(_document!)
          : null;
      _error = null;
    } catch (e, stack) {
      _error = e;
      if (widget.options.debug) {
        debugPrint('Error loading Tagflow document: $e\n$stack');
      }
    }
    if (mounted) setState(() {});
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder(context, _error);
    }

    Widget? content;
    if (widget.document != null) {
      if (_document == null) {
        return widget.loadingBuilder(context);
      }
      content = (widget.registry ?? TagflowComponentRegistry.builtIn).render(
        context,
        TagflowDocumentNode.root(
          id: '${_document!.id}:root',
          children: _document!.children,
        ),
      );
    } else if (_element != null) {
      content = _converter.convert(_element!, context);
    } else {
      return widget.loadingBuilder(context);
    }

    return widget.options.selectable.enabled
        ? SelectionArea(child: content)
        : content;
  }

  @override
  Widget build(BuildContext context) {
    return TagflowScope(
      options: widget.options,
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
      ..add(DiagnosticsProperty<TagflowOptions>('options', widget.options))
      ..add(DiagnosticsProperty<TagflowNode>('element', _element))
      ..add(DiagnosticsProperty<Object>('error', _error));
  }
}
