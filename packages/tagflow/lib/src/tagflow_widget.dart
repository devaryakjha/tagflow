import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

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
  final Widget Function(BuildContext context, Object? error) errorBuilder;

  /// Loading widget shown while parsing
  final Widget? loadingBuilder;

  @override
  State<Tagflow> createState() => _TagflowState();
}

Widget _defaultErrorWidget(BuildContext context, Object? error) {
  return Text(
    'Failed to render HTML: $error',
    style: const TextStyle(color: Color(0xFFB00020)),
  );
}

Future<TagflowElement> _parseHtml(String html) async {
  final parser = TagflowParser();
  return parser.parse(html);
}

class _TagflowState extends State<Tagflow> {
  late final TagflowConverter converter;

  @override
  void initState() {
    super.initState();
    converter = TagflowConverter()..addAllConverters(widget.converters);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _parseHtml(widget.html),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder ?? const SizedBox();
        }

        if (snapshot.hasError) {
          return widget.errorBuilder(context, snapshot.error);
        }

        final element = snapshot.data!;
        return converter.convert(element, context);
      },
    );
  }
}
