// Renders an HTML table with merged cells through tagflow_table.
//
// The full gallery is in examples/tagflow in the repository.
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

void main() => runApp(const TagflowTableExampleApp());

/// Example app.
class TagflowTableExampleApp extends StatelessWidget {
  /// Creates the example app.
  const TagflowTableExampleApp({super.key});

  static const _html = '''
<table border="1">
  <caption>Quarterly results</caption>
  <tr><th>Region</th><th colspan="2">Revenue</th></tr>
  <tr><td rowspan="2">North</td><td>Q1</td><td>120</td></tr>
  <tr><td>Q2</td><td>140</td></tr>
  <tr><td>South</td><td>Q1</td><td>90</td></tr>
</table>
''';

  // Create the registry once, outside build, so unchanged nodes reuse
  // their build.
  static final _registry = TagflowComponentRegistry(
    extensions: [tagflowTableComponents()],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tagflow_table example',
      home: Scaffold(
        appBar: AppBar(title: const Text('tagflow_table')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Tagflow.html(html: _html, registry: _registry),
        ),
      ),
    );
  }
}
