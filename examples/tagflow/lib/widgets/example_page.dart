// An abstract class that defines the interface for a page that
// contains an example.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagflow/tagflow.dart';

abstract class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  String get title;

  String get html;

  List<ElementConverter> get converters => const [];

  WidgetBuilder? get loadingBuilder {
    return (_) => const Center(child: CircularProgressIndicator());
  }

  Widget Function(BuildContext, Object?)? get errorBuilder {
    return (context, error) {
      return Text(
        'Failed to render HTML: $error',
        style: const TextStyle(color: Color(0xFFB00020)),
      );
    };
  }

  TagflowOptions? get options => null;

  @override
  Widget build(BuildContext context) {
    return TagflowThemeProvider(
      theme: TagflowTheme.fromTheme(
        Theme.of(context),
        fontFamily: GoogleFonts.inter().fontFamily,
        codeFontFamily: GoogleFonts.spaceMono().fontFamily,
      ),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Tagflow(
              options: options,
              key: ValueKey(title),
              converters: converters,
              html: html,
              loadingBuilder: loadingBuilder,
              errorBuilder: errorBuilder,
            ),
          ),
        ),
      ),
    );
  }
}
