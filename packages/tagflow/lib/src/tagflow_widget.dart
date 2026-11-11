import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/src/adapters/html_adapter.dart';
import 'package:tagflow/src/adapters/markdown_adapter.dart';
import 'package:tagflow/src/converter/converter.dart';
import 'package:tagflow/src/core/models/models.dart';
import 'package:tagflow/src/render/render.dart';
import 'package:tagflow/src/runtime/runtime.dart';
import 'package:tagflow/src/style/theme.dart';
import 'package:tagflow/src/tagflow_options.dart';

/// Legacy widget-level error builder typedef.
@Deprecated(
  'Use TagflowErrorWidgetBuilder instead. Will be removed in tagflow 2.0.',
)
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

/// Document ids used by [Tagflow.html] and [Tagflow.markdown] when the caller
/// does not supply one. They do not depend on the content, so editing the
/// source keeps the root key and unchanged nodes keep their widget state.
const _defaultHtmlDocumentId = 'tagflow-html';
const _defaultMarkdownDocumentId = 'tagflow-markdown';

/// Main widget for rendering rich content.
class Tagflow extends StatefulWidget {
  /// Creates a new legacy HTML [Tagflow] widget.
  ///
  /// Equivalent to [Tagflow.html]; kept for compatibility through 1.x.
  @Deprecated('Use Tagflow.html(...) instead. Will be removed in tagflow 2.0.')
  const Tagflow({
    required String this.html,
    this.theme,
    @Deprecated(
      'Legacy converter API. Use registry: TagflowComponentRegistry(...) '
      'instead. Will be removed in tagflow 2.0.',
    )
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    @Deprecated(
      'Use viewOptions: TagflowViewOptions(...) instead. '
      'Will be removed in tagflow 2.0.',
    )
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
       documentId = null,
       renderTheme = null,
       adapter = null,
       registry = null,
       markdown = null,
       markdownAdapter = null;

  /// Creates a new [Tagflow] widget from HTML.
  ///
  /// [documentId] names the adapted document. Without it the id stays the same
  /// for the life of the widget, so changing [html] updates the rendered tree
  /// in place and unchanged nodes keep their state.
  const Tagflow.html({
    required String this.html,
    this.adapter,
    this.documentId,
    this.theme,
    this.renderTheme,
    this.registry,
    @Deprecated(
      'Legacy converter API. Use registry: TagflowComponentRegistry(...) '
      'instead. Will be removed in tagflow 2.0.',
    )
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    @Deprecated(
      'Use viewOptions: TagflowViewOptions(...) instead. '
      'Will be removed in tagflow 2.0.',
    )
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
       markdown = null,
       markdownAdapter = null;

  /// Creates a new [Tagflow] widget from GitHub Flavored Markdown.
  ///
  /// Markdown is adapted by [markdownAdapter] (or a default
  /// [TagflowMarkdownAdapter]) into a [TagflowDocument] and rendered through
  /// [registry], so content policy and component overrides apply as they do
  /// for [Tagflow.document].
  ///
  /// [documentId] names the adapted document. Without it the id stays the same
  /// for the life of the widget, so changing [markdown] updates the rendered
  /// tree in place and unchanged nodes keep their state.
  const Tagflow.markdown({
    required String this.markdown,
    this.markdownAdapter,
    this.documentId,
    this.theme,
    this.renderTheme,
    this.registry,
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    super.key,
  }) : _viewOptions = viewOptions,
       _legacyOptions = null,
       _renderBoundary = null,
       html = null,
       document = null,
       adapter = null,
       converters = const [];

  /// Creates a new [Tagflow] widget from a native runtime document.
  const Tagflow.document(
    TagflowDocument this.document, {
    this.theme,
    this.renderTheme,
    this.registry,
    @Deprecated(
      'Legacy converter API. Use registry: TagflowComponentRegistry(...) '
      'instead. Will be removed in tagflow 2.0.',
    )
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    TagflowViewOptions? viewOptions,
    @Deprecated(
      'Use viewOptions: TagflowViewOptions(...) instead. '
      'Will be removed in tagflow 2.0.',
    )
    TagflowOptions? options,
    super.key,
  }) : assert(
         viewOptions == null || options == null,
         'Pass either viewOptions or options, not both.',
       ),
       _viewOptions = viewOptions,
       _legacyOptions = options,
       _renderBoundary = null,
       documentId = null,
       html = null,
       adapter = null,
       markdown = null,
       markdownAdapter = null;

  /// The HTML content to render.
  final String? html;

  /// The Markdown content to render.
  final String? markdown;

  /// Adapter used by [Tagflow.markdown] to produce a runtime document.
  final TagflowMarkdownAdapter? markdownAdapter;

  /// The canonical runtime document to render.
  final TagflowDocument? document;

  /// Id given to the document adapted from [html] or [markdown].
  ///
  /// When null, the widget uses an id that does not depend on the content, so
  /// it stays the same for the life of the widget. Supply a different id to
  /// remount the rendered tree on purpose.
  final String? documentId;

  /// Adapter used by [Tagflow.html] to produce a runtime document.
  final TagflowHtmlAdapter? adapter;

  /// Legacy theme.
  ///
  /// On the runtime renderer its named styles (default text style, `p`, `h1`
  /// to `h6`, `a`, `strong`, `em`, `code`, `pre`, `blockquote`, `th`, `mark`)
  /// are mapped onto a [TagflowRenderTheme] with
  /// [TagflowRenderTheme.fromTagflowTheme]. Other selectors only apply to the
  /// legacy converter pipeline. [renderTheme] is applied over it.
  final TagflowTheme? theme;

  /// Typed styling for the built-in components, merged over the enclosing
  /// [TagflowRenderThemeScope] and the defaults from the ambient [Theme].
  final TagflowRenderTheme? renderTheme;

  /// Semantic component registry used by the runtime entry points.
  final TagflowComponentRegistry? registry;

  /// Additional legacy converters to use.
  ///
  /// When non-empty, [Tagflow.html] renders through the legacy converter
  /// pipeline instead of [registry]. Removed in tagflow 2.0.
  @Deprecated(
    'Legacy converter API. Use registry: TagflowComponentRegistry(...) '
    'instead. Will be removed in tagflow 2.0.',
  )
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
  @Deprecated('Use viewOptions instead. Will be removed in tagflow 2.0.')
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

    // Only inputs that change the adapted document trigger a re-parse. Other
    // view options, such as inline tap callbacks that are new closures on
    // every parent build, only rebuild the rendered tree.
    if (oldWidget.html != widget.html ||
        oldWidget.document != widget.document ||
        oldWidget.documentId != widget.documentId ||
        oldWidget.adapter != widget.adapter ||
        oldWidget.markdown != widget.markdown ||
        oldWidget.markdownAdapter != widget.markdownAdapter ||
        oldWidget.viewOptions.debug != widget.viewOptions.debug ||
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
          switch (widget.markdown) {
            final markdown? =>
              (widget.markdownAdapter ?? const TagflowMarkdownAdapter()).parse(
                markdown,
                id: widget.documentId ?? _defaultMarkdownDocumentId,
              ),
            null => (widget.adapter ?? const TagflowHtmlAdapter()).parse(
              widget.html ?? '',
              id: widget.documentId ?? _defaultHtmlDocumentId,
              viewOptions: widget.viewOptions,
              renderBoundary: widget.renderBoundary,
            ),
          };
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
      return _buildErrorContent(context, _error);
    }

    if (_document == null) {
      return widget.loadingBuilder(context);
    }

    try {
      final content = _buildRenderedContent(context);
      return widget.viewOptions.selectable.enabled
          ? SelectionArea(child: content)
          : content;
    } catch (e, stack) {
      if (widget.viewOptions.debug) {
        debugPrint('Error rendering Tagflow content: $e\n$stack');
      }
      return _buildErrorContent(context, e);
    }
  }

  Widget _buildRenderedContent(BuildContext context) {
    if (_usesLegacyCompatibilityRenderer) {
      if (_element == null) return widget.loadingBuilder(context);
      return _converter.convert(_element!, context);
    }

    return (widget.registry ?? TagflowComponentRegistry.builtIn).render(
      context,
      TagflowDocumentNode.root(
        id: '${_document!.id}:root',
        children: _document!.children,
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, Object? error) {
    return (widget.viewOptions.errorBuilder ?? widget.errorBuilder)(
      context,
      error,
    );
  }

  bool get _usesLegacyCompatibilityRenderer =>
      widget.document == null && widget.converters.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final legacyTheme = widget.theme;
    final renderTheme = legacyTheme == null
        ? widget.renderTheme
        : TagflowRenderTheme.fromTagflowTheme(
            legacyTheme,
          ).merge(widget.renderTheme);
    final content = TagflowRenderThemeScope(
      theme: renderTheme,
      child: Builder(builder: _buildContent),
    );

    return TagflowScope.view(
      viewOptions: widget.viewOptions,
      child: legacyTheme != null
          ? TagflowThemeProvider.merge(
              context,
              theme: legacyTheme,
              child: content,
            )
          : content,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('html', widget.html))
      ..add(StringProperty('markdown', widget.markdown))
      ..add(StringProperty('documentId', widget.documentId))
      ..add(DiagnosticsProperty<TagflowDocument>('document', _document))
      ..add(DiagnosticsProperty<TagflowHtmlAdapter>('adapter', widget.adapter))
      ..add(
        DiagnosticsProperty<TagflowMarkdownAdapter>(
          'markdownAdapter',
          widget.markdownAdapter,
        ),
      )
      ..add(DiagnosticsProperty<TagflowTheme>('theme', widget.theme))
      ..add(
        DiagnosticsProperty<TagflowRenderTheme>(
          'renderTheme',
          widget.renderTheme,
        ),
      )
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
