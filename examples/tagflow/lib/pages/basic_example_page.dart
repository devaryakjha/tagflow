// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

class BasicExamplePage extends StatelessWidget {
  const BasicExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Tagflow(
          html: '<h1>Hello, world!</h1>'
              '<h2>Hello, world!</h2>'
              '<h3>Hello, world!</h3>'
              '<h4>Hello, world!</h4>'
              '<h5>Hello, world!</h5>'
              '<h6>Hello, world!</h6>'
              '========================'
              '<p>Hello, <b><i>world</i></b>!</p>'
              '========================',
          loadingBuilder: const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error) {
            return Text(
              'Failed to render HTML: $error',
              style: const TextStyle(color: Color(0xFFB00020)),
            );
          },
        ),
      ),
    );
  }
}
