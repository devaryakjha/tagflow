import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tagflow_example/utils/router.dart';
import 'package:tagflow_example/utils/style/theme.dart';

class TagflowExample extends StatefulWidget {
  const TagflowExample({super.key});

  @override
  State<TagflowExample> createState() => _TagflowExampleState();
}

class _TagflowExampleState extends State<TagflowExample> {
  late Future<void> pendingFonts;

  void _initiliaseApp() {
    pendingFonts = GoogleFonts.pendingFonts([
      GoogleFonts.inter(),
      GoogleFonts.spaceMono(),
    ]);
  }

  @override
  void initState() {
    _initiliaseApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: pendingFonts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return MaterialApp.router(
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          title: 'Tagflow Example',
          routerConfig: router,
        );
      },
    );
  }
}
