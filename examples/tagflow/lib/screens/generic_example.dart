import 'package:tagflow_example/widgets/example_page.dart';

const _html = '''
<h1>Hello, world!</h1><p>This is a paragraph.</p>
''';

final class GenericExample extends ExamplePage {
  const GenericExample({super.key})
      : super(
          title: 'Generic Example',
          html: _html,
        );
}
