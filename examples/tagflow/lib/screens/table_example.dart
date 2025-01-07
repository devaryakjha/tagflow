import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/example_page.dart';
import 'package:tagflow_table/tagflow_table.dart';

const _html = r'''
<h3>Basic Table</h3>
<table>
  <tr>
    <th>Header 1</th>
    <th>Header 2</th>
    <th>Header 3</th>
  </tr>
  <tr>
    <td>Row 1, Cell 1</td>
    <td>Row 1, Cell 2</td>
    <td>Row 1, Cell 3</td>
  </tr>
  <tr>
    <td>Row 2, Cell 1</td>
    <td>Row 2, Cell 2</td>
    <td>Row 2, Cell 3</td>
  </tr>
</table>
<h3>Styled Table</h3>
<table style="border: 1px solid #ddd; width: 100%;">
  <tr style="background-color: #f5f5f5;">
    <th style="padding: 8px; text-align: left;">Product</th>
    <th style="padding: 8px; text-align: right;">Price</th>
    <th style="padding: 8px; text-align: center;">Stock</th>
  </tr>
  <tr>
    <td style="padding: 8px;">Widget A</td>
    <td style="padding: 8px; text-align: right;">$10.00</td>
    <td style="padding: 8px; text-align: center;">In Stock</td>
  </tr>
  <tr style="background-color: #f9f9f9; color: #333;">
    <td style="padding: 8px;">Widget B</td>
    <td style="padding: 8px; text-align: right;">$15.00</td>
    <td style="padding: 8px; text-align: center;">Low Stock</td>
  </tr>
  <tr>
    <td style="padding: 8px;">Widget C</td>
    <td style="padding: 8px; text-align: right;">$20.00</td>
    <td style="padding: 8px; text-align: center;">Out of Stock</td>
  </tr>
</table>
<h3>Table with Colspan and Rowspan</h3>
<table>
  <tr>
    <th colspan="2">Merged Header</th>
    <th>Header 3</th>
  </tr>
  <tr>
    <td rowspan="2">Spans 2 Rows</td>
    <td>Row 1, Cell 2</td>
    <td>Row 1, Cell 3</td>
  </tr>
  <tr>
    <td>Row 2, Cell 2</td>
    <td>Row 2, Cell 3</td>
  </tr>
</table>
''';

final class TableExample extends ExamplePage {
  TableExample({super.key, super.title = 'Table'});

  var _useTagflowTable = true;

  @override
  List<ElementConverter<TagflowNode>> get converters =>
      !_useTagflowTable ? super.converters : [TagflowTableConverter()];

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Text('Use tagflow_table'),
            Switch(
              value: _useTagflowTable,
              onChanged: (value) {
                _useTagflowTable = value;
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  @override
  String get html => _html;
}
