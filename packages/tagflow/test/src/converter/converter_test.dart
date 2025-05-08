import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

class TestConverter extends ElementConverter {
  @override
  Set<String> get supportedTags => {'p', 'div'};

  @override
  Widget convert(
    TagflowNode element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return const SizedBox();
  }
}

void main() {
  group('ElementConverter', () {
    test('matches pseudo-selectors correctly', () {
      final converter = TestConverter();

      // Create a parent with multiple children
      final parent =
          const TagflowElement(
            tag: 'div',
            attributes: {'id': 'parent'},
            children: [
              TagflowElement(tag: 'p', attributes: {'id': 'first'}),
              TagflowElement(tag: 'p', attributes: {'id': 'middle'}),
              TagflowElement(tag: 'p', attributes: {'id': 'last'}),
            ],
          ).reparent();

      final firstChild = parent.children.first;
      final middleChild = parent.children[1];
      final lastChild = parent.children.last;

      // Test first-child selector
      expect(
        converter.matchPositiveSelector(firstChild, 'p:first-child'),
        isTrue,
      );
      expect(
        converter.matchPositiveSelector(middleChild, 'p:first-child'),
        isFalse,
      );

      // Test last-child selector
      expect(
        converter.matchPositiveSelector(lastChild, 'p:last-child'),
        isTrue,
      );
      expect(
        converter.matchPositiveSelector(middleChild, 'p:last-child'),
        isFalse,
      );
    });
  });
}
