import 'package:flutter/material.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

/// Hosts a single fixture/renderer pair for manual and profile benchmarks.
final class BenchmarkHost extends StatefulWidget {
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
  State<BenchmarkHost> createState() => _BenchmarkHostState();
}

final class _BenchmarkHostState extends State<BenchmarkHost> {
  AssetBundle? _assetBundle;
  String? _assetPath;
  late Future<String> _pendingHtml;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final assetBundle = DefaultAssetBundle.of(context);
    final assetPath = widget.fixture.htmlAssetPath;
    if (_assetBundle == assetBundle && _assetPath == assetPath) {
      return;
    }

    _assetBundle = assetBundle;
    _assetPath = assetPath;
    _pendingHtml = assetBundle.loadString(assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _pendingHtml,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to load fixture: ${widget.fixture.htmlAssetPath}',
            ),
          );
        }

        final html = snapshot.data;
        if (html == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final content = KeyedSubtree(
          key: BenchmarkHost.contentKey,
          child: widget.renderer.builder(context, html),
        );

        return ListView(
          key: BenchmarkHost.scrollKey,
          padding: const EdgeInsets.all(24),
          children: [
            if (widget.showChrome) ...[
              _BenchmarkHeader(
                fixture: widget.fixture,
                renderer: widget.renderer,
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
        if (renderer.notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final note in renderer.notes)
            Text('Note: $note', style: textTheme.bodySmall),
        ],
      ],
    );
  }
}
