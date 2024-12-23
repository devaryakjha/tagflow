import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  static ThemeData _createThemeData(Brightness brightness) {
    final theme = ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
    );

    return theme.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(theme.textTheme),
    );
  }

  static final theme = _createThemeData(Brightness.light);

  static final darkTheme = _createThemeData(Brightness.dark);
}
