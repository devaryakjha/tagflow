import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  static final theme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(),
    textTheme: TextTheme(
      bodyMedium: GoogleFonts.dmSans(),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(),
    textTheme: TextTheme(
      bodyMedium: GoogleFonts.dmSans(),
    ),
  );
}
