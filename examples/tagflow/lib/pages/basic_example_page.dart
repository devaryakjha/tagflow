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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Tagflow(
            html: '<h1>Hello, world! <- <i>h1</i> </h1>'
                '<h2>Hello, world! <- <i>h2</i> </h2>'
                '<h3>Hello, world! <- <i>h3</i> </h3>'
                '<h4>Hello, world! <- <i>h4</i> </h4>'
                '<h5>Hello, world! <- <i>h5</i> </h5>'
                '<h6>Hello, world! <- <i>h6</i> </h6>'
                '========================'
                '<p>Hello, <b><i>world</i></b>!</p>'
                '========================'
                '<h1>Image support</h1>'
                '<img src="https://picsum.photos/200/300?grayscale"/>'
                '<img src="https://picsum.photos/200/300"/>',
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
      ),
    );
  }
}
