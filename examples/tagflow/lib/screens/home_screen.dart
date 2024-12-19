import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tagflow_example/utils/examples.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagflow Examples'),
        centerTitle: false,
      ),
      body: ListView.separated(
        itemCount: allExamples.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          return ExampleCard(
            example: allExamples[index],
            onTap: () {
              context.push(allExamples[index].path);
            },
          );
        },
      ),
    );
  }
}

final class ExampleCard extends StatelessWidget {
  const ExampleCard({
    required this.example,
    required this.onTap,
    super.key,
  });

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
