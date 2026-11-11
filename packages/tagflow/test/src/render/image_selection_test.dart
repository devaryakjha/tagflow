import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart' show TagflowSelectableAdapter;
import 'package:tagflow/tagflow.dart';

final _document = TagflowDocument(
  id: 'doc',
  children: [
    TagflowDocumentNode.image(
      id: 'img',
      url: Uri.parse('https://example.com/a.png'),
      alt: 'A chart',
      width: 10,
      height: 10,
    ),
  ],
);

Future<String?> _selectionText(
  WidgetTester tester,
  TagflowSelectableOptions selectable,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Tagflow.document(
        _document,
        viewOptions: TagflowViewOptions(selectable: selectable),
      ),
    ),
  );
  // Image.network fails without a network in tests; only the adapter matters.
  tester.takeException();

  final adapters = tester.widgetList<TagflowSelectableAdapter>(
    find.byType(TagflowSelectableAdapter),
  );
  expect(adapters, hasLength(1));
  return adapters.single.text;
}

void main() {
  group('image selection on the runtime path', () {
    testWidgets('should not wrap images when selection is off', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Tagflow.document(_document)));
      tester.takeException();

      expect(find.byType(TagflowSelectableAdapter), findsNothing);
    });

    testWidgets('should select the alt text by default', (tester) async {
      final text = await _selectionText(
        tester,
        const TagflowSelectableOptions(enabled: true),
      );

      expect(text, 'A chart');
    });

    testWidgets('should select the alt text and URL for urlAndAlt', (
      tester,
    ) async {
      final text = await _selectionText(
        tester,
        const TagflowSelectableOptions(
          enabled: true,
          imageSelectionBehavior: TagflowImageSelectionBehavior.urlAndAlt,
        ),
      );

      expect(text, 'A chart — https://example.com/a.png');
    });

    testWidgets('should call the node text builder for custom', (tester) async {
      TagflowDocumentNode? seen;
      final text = await _selectionText(
        tester,
        TagflowSelectableOptions(
          enabled: true,
          imageSelectionBehavior: TagflowImageSelectionBehavior.custom,
          imageSelectionTextBuilder: (image, context) {
            seen = image;
            return '[image ${image.id}]';
          },
        ),
      );

      expect(text, '[image img]');
      expect(seen?.alt, 'A chart');
    });

    testWidgets('should fall back to the deprecated element builder', (
      tester,
    ) async {
      final text = await _selectionText(
        tester,
        TagflowSelectableOptions(
          enabled: true,
          imageSelectionBehavior: TagflowImageSelectionBehavior.custom,
          // ignore: deprecated_member_use_from_same_package, fallback test.
          imageSelectionBehaviorTextBuilder: (element, context) =>
              '${element.alt} at ${element.src}',
        ),
      );

      expect(text, 'A chart at https://example.com/a.png');
    });
  });
}
