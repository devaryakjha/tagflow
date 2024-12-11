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
  return Text(
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
    this.converters = const [],
    this.errorBuilder = _defaultErrorWidget,
    this.loadingBuilder,
    super.key,
  });

  /// The HTML content to render.
  final String html;

  /// Additional converters to use
  final List<ElementConverter> converters;

  /// Error builder for handling parsing/conversion errors
  final ErrorWidgetBuilder? errorBuilder;

  /// Loading widget shown while parsing
  final WidgetBuilder? loadingBuilder;

  @override
  State<Tagflow> createState() => _TagflowState();
}

Future<TagflowElement> _parseHtml(String html) async {
  final parser = TagflowParser();
  return parser.parse(html);
}

class _TagflowState extends State<Tagflow> {
  late final TagflowConverter converter;
  TagflowElement? element;

  @override
  void initState() {
    super.initState();
    converter = TagflowConverter()..addAllConverters(widget.converters);
  }

  @override
  void didUpdateWidget(covariant Tagflow oldWidget) {
    if (oldWidget.html != widget.html) {
      _parseHtml(widget.html).then((e) {
        element = e;
        setState(() {});
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.microtask(
        () async => element ??= await _parseHtml(widget.html),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return (widget.loadingBuilder ?? _defaultLoadingWidget)(context);
        }

        if (snapshot.hasError) {
          return (widget.errorBuilder ?? _defaultErrorWidget)(
            context,
            snapshot.error,
          );
        }

        final element = snapshot.data!;
        return converter.convert(element, context);
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties
      ..add(DiagnosticsProperty<String>('html', widget.html))
      ..add(
        DiagnosticsProperty<List<ElementConverter>>(
          'converters',
          widget.converters,
        ),
      )
      ..add(
        DiagnosticsProperty<TagflowElement>(
          'element',
          element,
          defaultValue: null,
          missingIfNull: true,
        ),
      );
  }
}
