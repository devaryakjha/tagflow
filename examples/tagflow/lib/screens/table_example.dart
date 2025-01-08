import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/example_page.dart';
import 'package:tagflow_table/tagflow_table.dart';

const _advancedTableHtml = r'''
<h3>Debug Table</h3>
<table>
  <tr>
    <td>1</td>
    <td>2</td>
    <td>3</td>
  </tr>
  <tr>
    <td>4</td>
    <td>5</td>
    <td>6</td>
  </tr>
</table>

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
  <tr>
    <th style="padding: 8px;">Product</th>
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

<h3>Complex Spanning Patterns</h3>
<table style="border: 1px solid #666; width: 100%;">
  <tr>
    <td rowspan="3" colspan="2" style="background-color: #f0f0f0; color: #333;">Large Cell<br/>Spans 3x2</td>
    <td>Top Right</td>
    <td rowspan="2">Spans 2 Rows</td>
  </tr>
  <tr>
    <td>Middle Right</td>
  </tr>
  <tr>
    <td colspan="2">Bottom Span</td>
  </tr>
  <tr>
    <td colspan="4" style="background-color: #f0f0f0; color: #333;">Full Width Cell</td>
  </tr>
</table>

<h3>Mixed Headers and Empty Cells</h3>
<table style="border: 2px solid #333;">
  <tr>
    <th rowspan="2">Category</th>
    <th colspan="3">Performance</th>
    <th rowspan="2">Notes</th>
  </tr>
  <tr>
    <th>Q1</th>
    <th>Q2</th>
    <th>Q3</th>
  </tr>
  <tr>
    <td>A</td>
    <td>Good</td>
    <td></td>
    <td>Excellent</td>
    <td rowspan="2">Consistent<br/>Performance</td>
  </tr>
  <tr>
    <td>B</td>
    <td colspan="3" style="text-align: center;">Under Review</td>
  </tr>
</table>

<h3>Nested Tables</h3>
<table style="border: 3px solid #444;">
  <tr>
    <td>
      <table style="border: 1px solid #999;">
        <tr>
          <td>Nested 1</td>
          <td>Nested 2</td>
        </tr>
      </table>
    </td>
    <td rowspan="2">Side Cell</td>
  </tr>
  <tr>
    <td>
      <table style="border: 1px dashed #999;">
        <tr>
          <td colspan="2">Nested Header</td>
        </tr>
        <tr>
          <td>Data 1</td>
          <td>Data 2</td>
        </tr>
      </table>
    </td>
  </tr>
</table>

<h3>Irregular Structure</h3>
<table style="border: 1px solid #888;">
  <tr>
    <td rowspan="4">Side</td>
    <td colspan="2">Top</td>
    <td rowspan="2">TR</td>
  </tr>
  <tr>
    <td rowspan="2">Middle Left</td>
    <td>Middle Center</td>
  </tr>
  <tr>
    <td colspan="2" rowspan="2">Bottom Right<br/>Large Cell</td>
  </tr>
  <tr>
    <td>Bottom Left</td>
  </tr>
</table>

<h3>Table with Caption</h3>
<table>
  <caption>Monthly Sales Report</caption>
  <tr>
    <th>Month</th>
    <th>Sales</th>
    <th>Growth</th>
  </tr>
  <tr>
    <td>January</td>
    <td>$10,000</td>
    <td>+5%</td>
  </tr>
  <tr>
    <td>February</td>
    <td>$12,000</td>
    <td>+20%</td>
  </tr>
</table>

<h3>Styled Table with Caption</h3>
<table style="border: 1px solid #ddd; width: 100%;">
  <caption style="font-weight: bold; color: #ff0000;">Quarterly Performance Overview</caption>
  <tr>
    <th style="padding: 8px;">Quarter</th>
    <th style="padding: 8px;">Revenue</th>
    <th style="padding: 8px;">Status</th>
  </tr>
  <tr>
    <td style="padding: 8px;">Q1</td>
    <td style="padding: 8px;">$50,000</td>
    <td style="padding: 8px; color: green;">On Track</td>
  </tr>
  <tr>
    <td style="padding: 8px;">Q2</td>
    <td style="padding: 8px;">$65,000</td>
    <td style="padding: 8px; color: green;">Exceeding</td>
  </tr>
</table>
''';
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
    <th style="padding: 8px;">Product</th>
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

  bool get useTagflowTable => getState<bool>('useTagflowTable') ?? true;

  void updateUseTagflowTable({bool? value}) {
    updateState<bool>('useTagflowTable', value ?? !useTagflowTable);
  }

  @override
  List<ElementConverter<TagflowNode>> get converters => !useTagflowTable
      ? super.converters
      : [
          TagflowTableConverter(),
          const TagflowTableCellConverter(),
        ];

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<void>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Use tagflow_table'),
                  const SizedBox(width: 16),
                  Switch(
                    value: useTagflowTable,
                    onChanged: (value) {
                      updateUseTagflowTable(value: value);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  String get html => useTagflowTable ? _advancedTableHtml : _html;
}
