import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart' as api;

void main() {
  test(
    'tagflow_table.dart exposes the beta-facing table extension surface',
    () {
      final registry = api.tagflowTableComponents(
        border: api.TagflowTableBorder.all(),
      );

      expect(registry, isA<TagflowComponentRegistry>());
      expect(const api.TagflowTableConverter(), isA<Object>());
      expect(const api.TagflowTableCellConverter(), isA<Object>());
    },
  );
}
