import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Error widget builder for handling parsing/conversion errors
typedef ErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object? error,
);

/// Default error widget builder
Widget _defaultErrorWidget(BuildContext context, Object? error) {
  return SelectableText(
    'Failed to render HTML: $error',
    style: const TextStyle(color: Color(0xFFB00020)),
  );
}

/// Default loading widget builder
Widget _defaultLoadingWidget(BuildContext context) {
  return const Center(child: CircularProgressIndicator());
}

/// Main widget for rendering HTML content.
class Tagflow extends StatefulWidget {
  /// Creates a new [Tagflow] widget.
  const Tagflow({
    required this.html,
    this.theme,
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder = _defaultLoadingWidget,
    this.options = TagflowOptions.defaults,
    super.key,
  });

  /// The HTML content to render.
  final String html;

  /// Custom theme for styling HTML elements
  final TagflowTheme? theme;

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
  TagflowNode? _element;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _converter = TagflowConverter(widget.converters);
    _parseHtml();
  }

  @override
  void didUpdateWidget(Tagflow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.html != widget.html) {
      _parseHtml();
    }

    if (!listEquals(oldWidget.converters, widget.converters)) {
      _converter = TagflowConverter(widget.converters);
      if (_element != null) setState(() {});
    }
  }

  Future<void> _parseHtml() async {
    try {
      const parser = TagflowParser();
      _element = await compute(parser.parse, widget.html);
      _error = null;
    } catch (e, stack) {
      _error = e;
      if (widget.options.debug) {
        debugPrint('Error parsing HTML: $e\n$stack');
      }
    }
    if (mounted) setState(() {});
  }

  Widget _buildContent(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder(context, _error);
    }

    if (_element == null) {
      return widget.loadingBuilder(context);
    }

    final content = _converter.convert(_element!, context);

    return widget.options.selectable.enabled
        ? SelectionArea(child: content)
        : content;
  }

  @override
  Widget build(BuildContext context) {
    return TagflowScope(
      options: widget.options,
      child: widget.theme != null
          ? TagflowThemeProvider(
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
      ..add(DiagnosticsProperty<TagflowTheme>('theme', widget.theme))
      ..add(IterableProperty<ElementConverter>('converters', widget.converters))
      ..add(DiagnosticsProperty<TagflowOptions>('options', widget.options))
      ..add(DiagnosticsProperty<TagflowNode>('element', _element))
      ..add(DiagnosticsProperty<Object>('error', _error));
  }
}
