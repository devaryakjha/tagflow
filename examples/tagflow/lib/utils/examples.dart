import 'package:flutter/widgets.dart';
import 'package:tagflow_example/widgets/example_page.dart';

/// A class that represents an example
final class Example {
  const Example({
    required this.title,
    required this.description,
    required this.path,
    required this.builder,
    required this.icon,
  });

  /// The title of the example
  final String title;

  /// The description of the example
  final String description;

  /// The path to the example
  final String path;

  /// The icon to display for the example
  final IconData icon;

  /// A builder that returns an [ExamplePage]
  final ExamplePage Function(BuildContext context) builder;
}

/// A list of all examples
final allExamples = [];
