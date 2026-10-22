import 'package:flutter/material.dart';

/// The theme mode shared by every gallery screen.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

/// An app bar action that switches the gallery between light and dark.
class ThemeModeToggle extends StatelessWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      key: const ValueKey('theme-mode-toggle'),
      tooltip: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
      },
    );
  }
}
