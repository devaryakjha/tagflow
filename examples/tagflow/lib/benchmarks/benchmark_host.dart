import 'package:flutter/material.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

/// Hosts a single fixture/renderer pair for manual and profile benchmarks.
final class BenchmarkHost extends StatelessWidget {
  const BenchmarkHost({
    required this.fixture,
    required this.renderer,
    this.showChrome = true,
    super.key,
  });

  /// Key for the profile-test scroll surface.
  static const scrollKey = ValueKey<String>('tagflow-benchmark-scroll');

  /// Key for the rendered fixture body.
  static const contentKey = ValueKey<String>('tagflow-benchmark-content');

  /// Fixture rendered by this host.
  final ProfileBenchmarkFixture fixture;

  /// Renderer implementation under measurement.
  final BenchmarkRenderer renderer;

  /// Whether to show manual-inspection metadata above the fixture.
  final bool showChrome;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: DefaultAssetBundle.of(context).loadString(fixture.htmlAssetPath),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Unable to load fixture: ${fixture.htmlAssetPath}'),
          );
        }

        final html = snapshot.data;
        if (html == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final content = KeyedSubtree(
          key: contentKey,
          child: renderer.builder(context, html),
        );

        return ListView(
          key: scrollKey,
          padding: const EdgeInsets.all(24),
          children: [
            if (showChrome) ...[
              _BenchmarkHeader(
                fixture: fixture,
                renderer: renderer,
                inputLength: html.length,
              ),
              const SizedBox(height: 24),
            ],
            content,
          ],
        );
      },
    );
  }
}

final class _BenchmarkHeader extends StatelessWidget {
  const _BenchmarkHeader({
    required this.fixture,
    required this.renderer,
    required this.inputLength,
  });

  final ProfileBenchmarkFixture fixture;
  final BenchmarkRenderer renderer;
  final int inputLength;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Benchmark', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Renderer: ${renderer.label}', style: textTheme.bodyMedium),
        Text('Fixture: ${fixture.id}', style: textTheme.bodyMedium),
        Text('Input: $inputLength chars', style: textTheme.bodySmall),
      ],
    );
  }
}
