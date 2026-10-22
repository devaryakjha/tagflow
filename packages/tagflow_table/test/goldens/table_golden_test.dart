@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

import '../../../tagflow/test/goldens/golden_harness.dart';

void main() {
  group('tagflow_table goldens', () {
    final registry = TagflowComponentRegistry(
      extensions: [tagflowTableComponents()],
    );

    tagflowGoldenTest(
      'table',
      registry: registry,
      html: '''
<table>
  <caption>Release plan</caption>
  <thead><tr><th>Phase</th><th>Version</th><th>Status</th></tr></thead>
  <tbody>
    <tr><td>Beta</td><td>1.0.0-beta.1</td><td>In progress</td></tr>
    <tr><td>Stable</td><td>1.0.0</td><td>Planned after beta feedback</td></tr>
  </tbody>
</table>
''',
    );

    tagflowGoldenTest(
      'table_border_spans',
      registry: registry,
      html: '''
<table border="2">
  <tr><th colspan="2">Merged header</th><th>Solo</th></tr>
  <tr><td rowspan="2">Tall</td><td>B1</td><td>C1</td></tr>
  <tr><td>B2</td><td style="text-align: right">C2</td></tr>
</table>
''',
    );
  });
}
