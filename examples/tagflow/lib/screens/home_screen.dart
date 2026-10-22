import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tagflow_example/utils/examples.dart';
import 'package:tagflow_example/utils/theme_mode.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagflow Examples'),
        centerTitle: false,
        actions: const [ThemeModeToggle()],
      ),
      body: ListView(
        children: [
          for (final section in ExampleSection.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                section.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            for (final example in allExamples)
              if (example.section == section)
                ExampleCard(
                  example: example,
                  onTap: () => context.push(example.path),
                ),
          ],
        ],
      ),
    );
  }
}

final class ExampleCard extends StatelessWidget {
  const ExampleCard({required this.example, required this.onTap, super.key});

  final Example example;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(example.title),
      subtitle: Text(example.description),
      onTap: onTap,
      leading: Icon(example.icon),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
