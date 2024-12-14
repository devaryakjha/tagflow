import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagflow_example/pages/home_page.dart';

void main() {
  runApp(const TagflowExample());
}

class TagflowExample extends StatelessWidget {
  const TagflowExample({super.key});

  @override
  Widget build(BuildContext context) {
    GoogleFonts.pendingFonts([GoogleFonts.inter(), GoogleFonts.spaceMono()]);
    ThemeData themeData(ColorScheme scheme) {
      const textTheme = TextTheme(
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.3,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      );
      return ThemeData(
        colorScheme: scheme,
        textTheme: GoogleFonts.interTextTheme(textTheme),
      );
    }

    return MaterialApp(
      title: 'Tagflow Example',
      theme: themeData(ColorScheme.fromSeed(seedColor: Colors.black)),
      darkTheme: themeData(
        ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}
