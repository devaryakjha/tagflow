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
      body: Tagflow(
        html:
            '<p>Hello, <i><b>world</b></i>!<img src="https://picsum.photos/seed/abc/200?grayscale" /></p>',
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
    );
  }
}
