import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final class AppTheme {
  static final theme = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadZincColorScheme.light(),
    textTheme: ShadTextTheme.fromGoogleFont(
      GoogleFonts.dmSans,
    ),
  );

  static final darkTheme = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadZincColorScheme.dark(),
    textTheme: ShadTextTheme.fromGoogleFont(
      GoogleFonts.dmSans,
    ),
  );
}
