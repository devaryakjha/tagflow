import 'package:tagflow/tagflow.dart';
import 'package:tagflow_example/widgets/example_page.dart';

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
''';

final class TableExample extends ExamplePage {
  const TableExample({super.key, super.title = 'Table'});

  @override
  List<ElementConverter<TagflowNode>> get converters => [
        // TagflowTableConverter(),
      ];

  @override
  String get html => _html;
}

/**
 * <h3>Table with Colspan and Rowspan</h3>
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
 */
