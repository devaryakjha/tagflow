import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

const _codec = TagflowNativeBlockCodec();
const _adapter = TagflowNativeBlockAdapter();

TagflowDocument _chartDocument() {
  return TagflowDocument(
    id: 'doc',
    children: [
      TagflowDocumentNode.custom(
        id: 'chart',
        type: 'chart',
        metadata: TagflowMetadata(const {'title': 'Sales'}),
        children: [TagflowDocumentNode.text(id: 'chart.0', text: 'Fallback')],
      ),
    ],
  );
}

void main() {
  group('custom node kind', () {
    test('should reject a blank custom type', () {
      expect(
        () => TagflowDocumentNode.custom(id: 'x', type: '  '),
        throwsArgumentError,
      );
    });

    test('should compare custom nodes by type', () {
      final a = TagflowDocumentNode.custom(id: 'x', type: 'chart');
      final b = TagflowDocumentNode.custom(id: 'x', type: 'map');

      expect(a, isNot(b));
      expect(a, TagflowDocumentNode.custom(id: 'x', type: 'chart'));
      expect(a.customType, 'chart');
      expect(TagflowDocumentNode.paragraph(id: 'p').customType, isNull);
    });

    testWidgets('should render a custom node with its registered builder', (
      tester,
    ) async {
      final registry = TagflowComponentRegistry(
        customComponents: {
          'chart': (context, node) =>
              Text('Chart: ${node.metadata.values['title']}'),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(_chartDocument(), registry: registry),
        ),
      );

      expect(find.text('Chart: Sales'), findsOneWidget);
      expect(find.text('Fallback', findRichText: true), findsNothing);
      expect(registry.registeredCustomTypes, {'chart'});
    });

    testWidgets('should take app custom builders over extension ones', (
      tester,
    ) async {
      final registry = TagflowComponentRegistry(
        extensions: [
          TagflowComponentRegistry.components(
            customComponents: {'chart': (context, node) => const Text('ext')},
          ),
        ],
        customComponents: {'chart': (context, node) => const Text('app')},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(_chartDocument(), registry: registry),
        ),
      );

      expect(find.text('app'), findsOneWidget);
      expect(find.text('ext'), findsNothing);
    });

    testWidgets('should render the children of an unregistered custom node', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(_chartDocument())),
      );

      expect(find.text('Fallback', findRichText: true), findsOneWidget);
    });
  });

  group('native custom blocks', () {
    test('should round-trip a custom block and keep its data', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.custom(
            id: 'c',
            type: 'product-card',
            attributes: const {'sku': 'A1'},
          ),
        ],
      );

      final json = _codec.encodeDocument(document);
      final decoded = _codec.decodeDocument(json);
      expect(_codec.encodeDocument(decoded), json);

      final node = _adapter.adapt(decoded).children.single;
      expect(node.kind, TagflowNodeKind.custom);
      expect(node.customType, 'product-card');
      expect(node.metadata.values['blockAttributes'], {
        'sku': 'A1',
        'type': 'product-card',
      });
    });

    test('should reject a custom block without a type during decode', () {
      for (final attributes in <Map<String, Object?>>[
        {},
        {'type': ''},
        {'type': 3},
      ]) {
        expect(
          () => _codec.decodeDocument({
            'id': 'doc',
            'schemaVersion': 1,
            'blocks': [
              {'id': 'c', 'kind': 'custom', 'attributes': attributes},
            ],
          }),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('blocks[0].attributes.type'),
            ),
          ),
          reason: '$attributes',
        );
      }
    });
  });
}
