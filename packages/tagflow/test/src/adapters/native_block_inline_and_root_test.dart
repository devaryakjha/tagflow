import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

const _codec = TagflowNativeBlockCodec();
const _adapter = TagflowNativeBlockAdapter();

Map<String, Object?> _envelope(List<Map<String, Object?>> blocks) {
  return {'id': 'doc', 'schemaVersion': 1, 'blocks': blocks};
}

Map<String, Object?> _text(Map<String, Object?> attributes) {
  return {'id': 't', 'kind': 'text', 'text': 'x', 'attributes': attributes};
}

void main() {
  group('native inline semantics', () {
    test('should round-trip text and container semantics', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.paragraph(
            id: 'p',
            children: [
              TagflowNativeBlock.text(id: 'p.0', text: 'plain '),
              TagflowNativeBlock.text(
                id: 'p.1',
                text: 'bold',
                semantics: const {TagflowInlineSemantic.strong},
              ),
              TagflowNativeBlock.container(
                id: 'p.2',
                semantics: const {
                  TagflowInlineSemantic.emphasis,
                  TagflowInlineSemantic.deleted,
                },
                children: [TagflowNativeBlock.text(id: 'p.2.0', text: 'gone')],
              ),
              TagflowNativeBlock.inlineCode(id: 'p.3', text: 'code'),
            ],
          ),
        ],
      );

      final json = _codec.encodeDocument(document);
      final decoded = _codec.decodeDocument(json);
      expect(_codec.encodeDocument(decoded), json);

      final paragraph = _adapter.adapt(decoded).children.single;
      expect(paragraph.children[0].presentation.inlineSemantics, isEmpty);
      expect(paragraph.children[1].presentation.inlineSemantics, {
        TagflowInlineSemantic.strong,
      });
      expect(paragraph.children[2].presentation.inlineSemantics, {
        TagflowInlineSemantic.emphasis,
        TagflowInlineSemantic.deleted,
      });
      expect(paragraph.children[3].kind, TagflowNodeKind.inlineCode);
    });

    testWidgets('should render native semantics in one paragraph', (
      tester,
    ) async {
      final document = _adapter.adapt(
        _codec.decodeDocument(
          _envelope([
            {
              'id': 'p',
              'kind': 'paragraph',
              'children': [
                {'id': 'p.0', 'kind': 'text', 'text': 'Hello '},
                {
                  'id': 'p.1',
                  'kind': 'text',
                  'text': 'bold',
                  'attributes': {
                    'semantics': ['strong'],
                  },
                },
              ],
            },
          ]),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(find.text('Hello bold', findRichText: true), findsOneWidget);
    });

    test('should reject unknown semantics during decode', () {
      expect(
        () => _codec.decodeDocument(
          _envelope([
            _text({
              'semantics': ['bold'],
            }),
          ]),
        ),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('blocks[0].attributes.semantics'),
          ),
        ),
      );
      expect(
        () => _codec.decodeDocument(
          _envelope([
            _text({'semantics': 'strong'}),
          ]),
        ),
        throwsFormatException,
      );
    });

    test('should reject mistyped typed attributes during decode', () {
      for (final attributes in [
        {'checked': 'yes'},
        {'expanded': 1},
        {'display': 'flex'},
        {'tone': 'loud'},
      ]) {
        expect(
          () => _codec.decodeDocument(_envelope([_text(attributes)])),
          throwsFormatException,
          reason: '$attributes',
        );
      }
    });

    test('should ignore unknown semantics on hand-built blocks', () {
      final document = _adapter.adapt(
        TagflowNativeBlockDocument(
          id: 'doc',
          schemaVersion: 1,
          blocks: [
            TagflowNativeBlock(
              id: 't',
              kind: TagflowNativeBlockKind.text,
              text: 'x',
              attributes: const {
                'semantics': ['strong', 'bold'],
              },
            ),
          ],
        ),
      );

      expect(document.children.single.presentation.inlineSemantics, {
        TagflowInlineSemantic.strong,
      });
    });
  });

  group('append-root patch', () {
    test('should round-trip and append blocks to the document root', () {
      final envelope = TagflowNativeBlockPatchEnvelope(
        documentId: 'doc',
        schemaVersion: 1,
        operations: [
          TagflowNativeBlockPatch.appendRootChildren(
            children: [TagflowNativeBlock.text(id: 'b', text: 'second')],
          ),
        ],
      );

      final json = _codec.encodePatchEnvelope(envelope);
      expect((json['operations']! as List).single, {
        'op': 'append-root',
        'blocks': [
          {'id': 'b', 'kind': 'text', 'text': 'second'},
        ],
      });

      final decoded = _codec.decodePatchEnvelope(json);
      final operation = decoded.operations.single;
      expect(operation.kind, TagflowNativeBlockPatchKind.appendRootChildren);
      expect(operation.targetNodeId, isNull);

      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.text(id: 'a', text: 'first')],
      ).applyPatches(_adapter.adaptPatches(decoded.operations));
      expect(document.children.map((node) => node.id), ['a', 'b']);
    });

    test('should append nothing for an empty append-root', () {
      final patch = _adapter.adaptPatch(
        TagflowNativeBlockPatch.appendRootChildren(children: const []),
      );
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.text(id: 'a', text: 'a')],
      ).applyPatch(patch);

      expect(document.children.map((node) => node.id), ['a']);
    });

    test('should reject duplicate ids appended to the root', () {
      final patch = _adapter.adaptPatch(
        TagflowNativeBlockPatch.appendRootChildren(
          children: [TagflowNativeBlock.text(id: 'a', text: 'again')],
        ),
      );
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.text(id: 'a', text: 'a')],
      );

      expect(() => document.applyPatch(patch), throwsStateError);
    });

    test('should still require a target for other operations', () {
      expect(
        () => _codec.decodePatchEnvelope({
          'id': 'doc',
          'schemaVersion': 1,
          'operations': [
            {'op': 'append-children', 'blocks': <Object?>[]},
          ],
        }),
        throwsFormatException,
      );
    });
  });

  group('callout', () {
    testWidgets('should render a callout with its title and tone colour', (
      tester,
    ) async {
      final document = _adapter.adapt(
        _codec.decodeDocument(
          _envelope([
            {
              'id': 'c',
              'kind': 'callout',
              'attributes': {'tone': 'danger', 'title': 'Careful'},
              'children': [
                {'id': 'c.0', 'kind': 'text', 'text': 'Body'},
              ],
            },
          ]),
        ),
      );
      const danger = Color(0xFFAA0000);

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            renderTheme: const TagflowRenderTheme(calloutDangerColor: danger),
          ),
        ),
      );

      expect(find.text('Careful'), findsOneWidget);
      expect(find.text('Body', findRichText: true), findsOneWidget);
      final decoration = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((box) => box.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((box) => box.border != null);
      expect((decoration.border! as Border).left.color, danger);
    });

    test('should leave tone null when a callout has none', () {
      final document = _adapter.adapt(
        TagflowNativeBlockDocument(
          id: 'doc',
          schemaVersion: 1,
          blocks: [TagflowNativeBlock.callout(id: 'c')],
        ),
      );

      expect(document.children.single.kind, TagflowNodeKind.callout);
      expect(document.children.single.tone, isNull);
      expect(document.children.single.title, isNull);
    });
  });
}
