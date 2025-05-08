import 'package:go_router/go_router.dart';
import 'package:tagflow_example/screens/home_screen.dart';
import 'package:tagflow_example/utils/examples.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    ...allExamples.map(
      (example) => GoRoute(
        path: example.path,
        builder: (context, state) => example.builder(context),
      ),
    ),
  ],
);
