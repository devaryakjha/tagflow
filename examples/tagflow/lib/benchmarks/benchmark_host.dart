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
  late Future<BenchmarkSourceDocument> _pendingDocument;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final assetBundle = DefaultAssetBundle.of(context);
    final assetPath = widget.fixture.source.assetPath;
    if (_assetBundle == assetBundle && _assetPath == assetPath) {
      return;
    }

    _assetBundle = assetBundle;
    _assetPath = assetPath;
    _pendingDocument = assetBundle
        .loadString(assetPath)
        .then(
          (data) => BenchmarkSourceDocument(
            type: widget.fixture.source.type,
            data: data,
            assetPath: assetPath,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BenchmarkSourceDocument>(
      future: _pendingDocument,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Unable to load fixture: ${widget.fixture.source.assetPath}',
            ),
          );
        }

        final document = snapshot.data;
        if (document == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final content = KeyedSubtree(
          key: BenchmarkHost.contentKey,
          child: widget.renderer.build(context, document),
        );

        return ListView(
          key: BenchmarkHost.scrollKey,
          padding: const EdgeInsets.all(24),
          children: [
            if (widget.showChrome) ...[
              _BenchmarkHeader(
                fixture: widget.fixture,
                renderer: widget.renderer,
                inputType: document.type,
                inputLength: document.data.length,
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
    required this.inputType,
    required this.inputLength,
  });

  final ProfileBenchmarkFixture fixture;
  final BenchmarkRenderer renderer;
  final BenchmarkSourceType inputType;
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
        Text(
          'Input: ${inputType.name}, $inputLength chars',
          style: textTheme.bodySmall,
        ),
        if (renderer.notes.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final note in renderer.notes)
            Text('Note: $note', style: textTheme.bodySmall),
        ],
      ],
    );
  }
}
