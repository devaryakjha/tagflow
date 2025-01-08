import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('ListConverter', () {
    test('supports ul and ol tags', () {
      const converter = ListConverter();
      expect(converter.supportedTags, {'ul', 'ol'});
    });

    testWidgets('renders unordered list', (tester) async {
      const element = TagflowElement(
        tag: 'ul',
        children: [
          TagflowElement(tag: 'li', textContent: 'Item 1'),
          TagflowElement(tag: 'li', textContent: 'Item 2'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagflowThemeProvider(
              theme: const TagflowTheme.raw(
                defaultStyle: TagflowStyle.empty,
                styles: {},
              ),
              child: Builder(
                builder: (context) {
                  final widget = TagflowConverter().convert(element, context);
                  return widget;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Item 1', findRichText: true), findsOneWidget);
      expect(find.textContaining('Item 2', findRichText: true), findsOneWidget);
    });
  });
}
