import 'package:flutter/material.dart';
import 'package:tagflow_example/pages/code_example.page.dart';
import 'package:tagflow_example/pages/image_example.page.dart';
import 'package:tagflow_example/pages/typography_example.page.dart';
import 'package:tagflow_example/widgets/example_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagflow Examples'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Typography Examples',
            description: 'Examples of how to use typography',
            icon: Icons.format_quote,
            builder: (context) => const TypographyExample(),
          ),
          _buildSection(
            context,
            title: 'Image Examples',
            description: 'Examples of how to use images',
            icon: Icons.image,
            builder: (context) => const ImageExample(),
          ),
          // More text examples, for code blocks
          _buildSection(
            context,
            title: 'Code Examples',
            description: 'Examples of how to use code blocks',
            icon: Icons.code,
            builder: (context) => const CodeExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required ExamplePage Function(BuildContext) builder,
  }) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute<void>(builder: builder));
        },
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
