import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagflow/tagflow.dart';

abstract class ExamplePage extends StatelessWidget {
  const ExamplePage({required this.title, super.key});

  const factory ExamplePage.placeholder({required String title, Key? key}) =
      _PlaceholderExample;

  final String title;
  String get html;

  TagflowTheme createTheme(BuildContext context) => TagflowTheme.article(
        baseTextStyle: Theme.of(context).textTheme.bodyMedium!,
        headingTextStyle: Theme.of(context).textTheme.headlineMedium!,
        codeTextStyle:
            GoogleFonts.spaceMonoTextTheme(Theme.of(context).textTheme)
                .bodyMedium,
        codeFontFamily: GoogleFonts.spaceMono().fontFamily,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.refresh),
      ),
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Tagflow(
          html: html,
          theme: createTheme(context),
          options: TagflowOptions(
            selectable: const TagflowSelectableOptions(
              enabled: true,
            ),
            linkTapCallback: (url, attributes) {
              print('linkTapCallback: $url, $attributes');
            },
          ),
        ),
      ),
    );
  }
}

final class _PlaceholderExample extends ExamplePage {
  const _PlaceholderExample({required super.title, super.key}) : super();

  @override
  String get html => '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Placeholder'),
      ),
      body: const Placeholder(),
    );
  }
}
