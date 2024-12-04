import 'package:flutter/material.dart';
import 'package:tagflow_example/pages/home_page.dart';

void main() {
  runApp(const TagflowExample());
}

class TagflowExample extends StatelessWidget {
  const TagflowExample({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData themeData(ColorScheme scheme) => ThemeData(
          colorScheme: scheme,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
        );
    return MaterialApp(
      title: 'Tagflow Example',
      theme: themeData(ColorScheme.fromSeed(seedColor: Colors.black)),
      darkTheme: themeData(
        ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}
