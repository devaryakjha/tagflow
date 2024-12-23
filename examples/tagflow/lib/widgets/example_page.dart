import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

abstract class ExamplePage extends StatelessWidget {
  const ExamplePage({required this.title, required this.html, super.key});

  const factory ExamplePage.placeholder({required String title, Key? key}) =
      _PlaceholderExample;

  final String title;
  final String html;

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
      body: Tagflow(
        html: html,
        theme: TagflowTheme.fromTheme(
          Theme.of(context),
          h1Style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

final class _PlaceholderExample extends ExamplePage {
  const _PlaceholderExample({required super.title, super.key})
      : super(html: '');

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
