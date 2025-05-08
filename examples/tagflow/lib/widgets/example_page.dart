import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagflow/tagflow.dart';
import 'package:url_launcher/url_launcher_string.dart';

final _key = GlobalKey<_ExamplePageState>();

abstract class ExamplePage extends StatefulWidget {
  ExamplePage({required this.title, Key? key}) : super(key: key ?? _key);

  factory ExamplePage.placeholder({required String title, Key? key}) =>
      _PlaceholderExample(title: title, key: key);

  final String title;
  String get html;

  List<ElementConverter<TagflowNode>> get converters => [];

  TagflowTheme createTheme(BuildContext context) {
    final theme = Theme.of(context);
    final codeTextTheme = GoogleFonts.spaceMonoTextTheme(theme.textTheme);
    return TagflowTheme.fromTheme(
      theme,
      codeStyle: codeTextTheme.bodyMedium,
      inlineCodePadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
    );
  }

  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(title: Text(title));
  }

  @override
  State<ExamplePage> createState() => _ExamplePageState();

  Widget? build(BuildContext context) => null;

  void updateState<T>(String key, T value) {
    _key.currentState?.updateState(key, value);
  }

  T? getState<T>(String key) => _key.currentState?.getState<T>(key);
}

class _ExamplePageState extends State<ExamplePage> {
  final Map<String, dynamic> _state = {};

  T? getState<T>(String key) => _state[key] as T?;

  void updateState<T>(String key, T value) {
    _state[key] = value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context) ??
        Scaffold(
          appBar: widget.buildAppBar(context),
          body: SingleChildScrollView(
            child: Tagflow(
              html: widget.html,
              converters: widget.converters,
              theme: widget.createTheme(context),
              options: TagflowOptions(
                selectable: const TagflowSelectableOptions(enabled: true),
                linkTapCallback: (url, attributes) async {
                  if (await canLaunchUrlString(url)) {
                    await launchUrlString(url);
                  }
                },
              ),
            ),
          ),
        );
  }
}

final class _PlaceholderExample extends ExamplePage {
  _PlaceholderExample({required super.title, super.key});

  @override
  String get html => '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Placeholder')),
      body: const Placeholder(),
    );
  }
}
