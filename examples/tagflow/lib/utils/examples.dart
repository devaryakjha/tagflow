import 'package:flutter/material.dart';
import 'package:tagflow_example/screens/article_example.dart';
import 'package:tagflow_example/screens/code_example.dart';
import 'package:tagflow_example/screens/image_example.dart';
import 'package:tagflow_example/screens/table_example.dart';
import 'package:tagflow_example/screens/typography_example.dart';
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
final allExamples = <Example>[
  Example(
    title: 'Typography',
    description: 'A simple example of typography',
    path: '/typography',
    builder: (context) => const TypographyExample(),
    icon: Icons.text_fields,
  ),
  // article example
  Example(
    title: 'Article',
    description: 'A simple example of an article',
    path: '/article',
    builder: (context) => const ArticleExample(),
    icon: Icons.article,
  ),
  // table example
  Example(
    title: 'Table',
    description: 'A demonstration of HTML table rendering',
    path: '/table',
    builder: (context) => const TableExample(),
    icon: Icons.table_chart,
  ),
  // // list example
  // Example(
  //   title: 'Lists',
  //   description: 'Examples of ordered and unordered lists',
  //   path: '/lists',
  //   builder: (context) => const ListExample(),
  //   icon: Icons.format_list_bulleted,
  // ),
  // // form example
  // Example(
  //   title: 'Forms',
  //   description: 'Interactive form elements and inputs',
  //   path: '/forms',
  //   builder: (context) => const FormExample(),
  //   icon: Icons.input,
  // ),
  // // image example
  Example(
    title: 'Images',
    description: 'Image handling and responsive layouts',
    path: '/images',
    builder: (context) => const ImageExample(),
    icon: Icons.image,
  ),
  // code example
  Example(
    title: 'Code Blocks',
    description: 'Syntax highlighting and code formatting',
    path: '/code',
    builder: (context) => const CodeExample(),
    icon: Icons.code,
  ),
];
