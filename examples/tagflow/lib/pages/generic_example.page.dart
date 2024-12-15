import 'package:tagflow_example/widgets/example_page.dart';

const _html = '''
<h3>Horizontal Rule with Attributes</h3>
<hr style="color: #ff0000; height: 5px;">
''';

final class GenericExample extends ExamplePage {
  const GenericExample({super.key});

  @override
  String get html => _html;

  @override
  String get title => 'Generic Example';
}
