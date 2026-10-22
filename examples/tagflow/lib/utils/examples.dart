import 'package:flutter/material.dart';
import 'package:tagflow_example/screens/article_example.dart';
import 'package:tagflow_example/screens/code_example.dart';
import 'package:tagflow_example/screens/content_policy_example.dart';
import 'package:tagflow_example/screens/document_patch_example.dart';
import 'package:tagflow_example/screens/image_example.dart';
import 'package:tagflow_example/screens/internal_app_validation_screen.dart';
import 'package:tagflow_example/screens/markdown_example.dart';
import 'package:tagflow_example/screens/native_json_example.dart';
import 'package:tagflow_example/screens/reference_app_route_screen.dart';
import 'package:tagflow_example/screens/streaming_example.dart';
import 'package:tagflow_example/screens/table_example.dart';
import 'package:tagflow_example/screens/typography_example.dart';

/// A group of examples on the gallery home screen.
enum ExampleSection {
  inputs('Inputs'),
  live('Live content'),
  components('Components'),
  safety('Safety'),
  validation('Validation');

  const ExampleSection(this.label);

  /// The heading shown above the section.
  final String label;
}

/// A class that represents an example
final class Example {
  const Example({
    required this.section,
    required this.title,
    required this.description,
    required this.path,
    required this.builder,
    required this.icon,
  });

  /// The gallery section the example belongs to
  final ExampleSection section;

  /// The title of the example
  final String title;

  /// The description of the example
  final String description;

  /// The path to the example
  final String path;

  /// The icon to display for the example
  final IconData icon;

  /// A builder that returns the example screen.
  final Widget Function(BuildContext context) builder;
}

/// A list of all examples, in gallery order
final allExamples = <Example>[
  Example(
    section: ExampleSection.inputs,
    title: 'HTML typography',
    description: 'Headings, inline styles and text containers from HTML',
    path: '/typography',
    builder: (context) => TypographyExample(),
    icon: Icons.text_fields,
  ),
  Example(
    section: ExampleSection.inputs,
    title: 'HTML article',
    description: 'A long-form article adapted from HTML',
    path: '/article',
    builder: (context) => ArticleExample(),
    icon: Icons.article,
  ),
  Example(
    section: ExampleSection.inputs,
    title: 'Markdown',
    description: 'GitHub Flavored Markdown through the Markdown adapter',
    path: '/markdown',
    builder: (context) => const MarkdownExample(),
    icon: Icons.notes,
  ),
  Example(
    section: ExampleSection.inputs,
    title: 'Native JSON Transport',
    description: 'Decode trusted JSON blocks and apply semantic patches',
    path: '/native-json',
    builder: (context) => const NativeJsonExample(),
    icon: Icons.data_object,
  ),
  Example(
    section: ExampleSection.live,
    title: 'Live streaming',
    description: 'A simulated token stream rendered as it arrives',
    path: '/streaming',
    builder: (context) => const StreamingExample(),
    icon: Icons.stream,
  ),
  Example(
    section: ExampleSection.live,
    title: 'Document patches',
    description: 'Append, insert, replace and remove nodes in place',
    path: '/patches',
    builder: (context) => const DocumentPatchExample(),
    icon: Icons.difference,
  ),
  Example(
    section: ExampleSection.components,
    title: 'Tables',
    description: 'Built-in tables and the tagflow_table extension',
    path: '/table',
    builder: (context) => TableExample(),
    icon: Icons.table_chart,
  ),
  Example(
    section: ExampleSection.components,
    title: 'Images',
    description: 'Image handling and responsive layouts',
    path: '/images',
    builder: (context) => ImageExample(),
    icon: Icons.image,
  ),
  Example(
    section: ExampleSection.components,
    title: 'Code blocks',
    description: 'Syntax highlighting hook and copy button',
    path: '/code',
    builder: (context) => const CodeExample(),
    icon: Icons.code,
  ),
  Example(
    section: ExampleSection.safety,
    title: 'Content policy',
    description: 'Blocked tags and URLs, dropped or kept as placeholders',
    path: '/content-policy',
    builder: (context) => const ContentPolicyExample(),
    icon: Icons.shield,
  ),
  Example(
    section: ExampleSection.validation,
    title: 'Reference App Route',
    description: 'A reviewable route for app-authored rich content',
    path: '/reference-app-route',
    builder: (context) => const ReferenceAppRouteScreen(),
    icon: Icons.dynamic_feed,
  ),
  Example(
    section: ExampleSection.validation,
    title: 'Internal App Validation',
    description: 'Runtime fixture for controlled app-authored content',
    path: '/internal-app-validation',
    builder: (context) => const InternalAppValidationScreen(),
    icon: Icons.fact_check,
  ),
];
