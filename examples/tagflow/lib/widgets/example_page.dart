import 'package:flutter/material.dart';

abstract class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  String get title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(title),
      ),
    );
  }
}
