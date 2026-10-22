import 'package:flutter/material.dart';
import 'package:tagflow_example/utils/theme_mode.dart';

/// A scrollable gallery screen with a title, a short explanation and the
/// theme toggle.
class GalleryScaffold extends StatelessWidget {
  const GalleryScaffold({
    required this.title,
    required this.description,
    required this.children,
    this.actions = const [],
    super.key,
  });

  final String title;

  /// What the screen demonstrates, shown above [children].
  final String description;

  /// Controls placed under [description], such as buttons and toggles.
  final List<Widget> actions;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: const [ThemeModeToggle()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(description, style: theme.textTheme.bodySmall),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: actions),
          ],
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }
}
