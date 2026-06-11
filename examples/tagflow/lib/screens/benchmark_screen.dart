import 'package:flutter/material.dart';
import 'package:tagflow_example/benchmarks/benchmark_host.dart';
import 'package:tagflow_example/benchmarks/fixtures.dart';
import 'package:tagflow_example/benchmarks/renderer_registry.dart';

/// Manual host for Tagflow profile benchmark fixtures.
final class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({
    this.fixtureId = defaultProfileBenchmarkFixtureId,
    this.rendererId = defaultBenchmarkRendererId,
    this.showFixturePicker = true,
    super.key,
  });

  /// Initial benchmark fixture id.
  final String fixtureId;

  /// Benchmark renderer id.
  final String rendererId;

  /// Whether the manual fixture picker should be shown.
  final bool showFixturePicker;

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

final class _BenchmarkScreenState extends State<BenchmarkScreen> {
  late String fixtureId = widget.fixtureId;
  late String rendererId = widget.rendererId;

  void _selectFixture(String value) {
    final fixture = profileBenchmarkFixtureById(value);
    final nextRendererId =
        benchmarkRendererById(rendererId).supports(fixture.source.type)
        ? rendererId
        : benchmarkRenderersForSourceType(fixture.source.type).first.id;
    setState(() {
      fixtureId = value;
      rendererId = nextRendererId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final renderer = benchmarkRendererById(rendererId);
    final fixture = profileBenchmarkFixtureById(fixtureId);
    final host = BenchmarkHost(
      fixture: fixture,
      renderer: renderer,
      showChrome: widget.showFixturePicker,
    );

    if (!widget.showFixturePicker) {
      return Scaffold(body: host);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Benchmarks')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FixturePicker(
            selectedFixtureId: fixtureId,
            onSelected: _selectFixture,
          ),
          _RendererPicker(
            selectedRendererId: rendererId,
            fixture: fixture,
            onSelected: (value) => setState(() => rendererId = value),
          ),
          const Divider(height: 1),
          Expanded(child: host),
        ],
      ),
    );
  }
}

final class _RendererPicker extends StatelessWidget {
  const _RendererPicker({
    required this.selectedRendererId,
    required this.fixture,
    required this.onSelected,
  });

  final String selectedRendererId;
  final ProfileBenchmarkFixture fixture;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final compatibleRenderers = benchmarkRenderersForSourceType(
      fixture.source.type,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SegmentedButton<String>(
        segments: [
          for (final rendererId in compatibleRenderers.map((item) => item.id))
            ButtonSegment<String>(
              value: rendererId,
              label: Text(benchmarkRendererById(rendererId).label),
            ),
        ],
        selected: {selectedRendererId},
        onSelectionChanged: (selection) => onSelected(selection.single),
      ),
    );
  }
}

final class _FixturePicker extends StatelessWidget {
  const _FixturePicker({
    required this.selectedFixtureId,
    required this.onSelected,
  });

  final String selectedFixtureId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<String>(
        segments: [
          for (final fixtureId in profileBenchmarkFixtureIds)
            ButtonSegment<String>(value: fixtureId, label: Text(fixtureId)),
        ],
        selected: {selectedFixtureId},
        onSelectionChanged: (selection) => onSelected(selection.single),
      ),
    );
  }
}
