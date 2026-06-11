import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowComponentRegistry', () {
    test(
      'can render every semantic node kind through a component or fallback',
      () {
        final registry = TagflowComponentRegistry.builtIn;

        for (final kind in TagflowNodeKind.values) {
          expect(registry.canRender(kind), isTrue, reason: '$kind');
        }

        expect(registry.hasComponent(TagflowNodeKind.paragraph), isTrue);
        expect(registry.hasComponent(TagflowNodeKind.text), isTrue);
        expect(registry.hasComponent(TagflowNodeKind.unsupported), isFalse);
      },
    );

    testWidgets('uses app override before built-in component', (tester) async {
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            return const Text('Paragraph override');
          },
        },
      );
      final node = TagflowDocumentNode.paragraph(
        id: 'p1',
        children: [TagflowDocumentNode.text(id: 't1', text: 'Built-in text')],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) => registry.render(context, node)),
        ),
      );

      expect(find.text('Paragraph override'), findsOneWidget);
      expect(find.text('Built-in text'), findsNothing);
    });

    testWidgets('renders unsupported nodes with predictable fallback', (
      tester,
    ) async {
      final node = TagflowDocumentNode.unsupported(
        id: 'unsupported1',
        unsupportedReason: 'custom element',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TagflowComponentRegistry.builtIn.render(context, node);
            },
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.textContaining('custom element'), findsNothing);
    });
  });
}
