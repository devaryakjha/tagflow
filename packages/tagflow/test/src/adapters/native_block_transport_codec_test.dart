import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowNativeBlockCodec', () {
    const codec = TagflowNativeBlockCodec();

    test('decodes document JSON and adapts while preserving ids and order', () {
      final document = codec.decodeDocument({
        'id': 'article',
        'schemaVersion': 1,
        'revision': 'cms-rev-7',
        'metadata': {'surface': 'detail'},
        'source': {'kind': 'json', 'adapter': 'cms', 'uri': 'cms://articles/7'},
        'blocks': [
          {
            'id': 'title',
            'kind': 'heading',
            'attributes': {'level': 2},
            'children': [
              {'id': 'title.text', 'kind': 'text', 'text': 'Launch day'},
            ],
          },
          {
            'id': 'intro',
            'kind': 'paragraph',
            'children': [
              {'id': 'intro.a', 'kind': 'text', 'text': 'Read '},
              {
                'id': 'intro.link',
                'kind': 'link',
                'attributes': {'url': 'https://example.com/guide'},
                'children': [
                  {'id': 'intro.link.text', 'kind': 'text', 'text': 'guide'},
                ],
              },
              {'id': 'intro.b', 'kind': 'text', 'text': ' first.'},
            ],
          },
        ],
      });

      final adapted = const TagflowNativeBlockAdapter().adapt(document);

      expect(document.id, 'article');
      expect(document.revision, 'cms-rev-7');
      expect(document.metadata['surface'], 'detail');
      expect(document.source?.adapter, 'cms');
      expect(adapted.children.map((node) => node.id), ['title', 'intro']);
      expect(adapted.nodeById('intro.link')?.kind, TagflowNodeKind.link);
      expect(adapted.nodeById('intro.link.text')?.text, 'guide');
      adapted.validateUniqueNodeIds();
    });

    test('encodes document JSON using the supported transport fields', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        revision: 'rev-1',
        metadata: TagflowMetadata(const {'locale': 'en-IN'}),
        source: TagflowSourceInfo(
          kind: TagflowSourceKind.json,
          adapter: 'native_block_v1',
          uri: Uri.parse('cms://documents/doc'),
        ),
        blocks: [
          TagflowNativeBlock.paragraph(
            id: 'p',
            children: [TagflowNativeBlock.text(id: 'p.text', text: 'Hello')],
          ),
        ],
      );

      expect(codec.encodeDocument(document), {
        'id': 'doc',
        'schemaVersion': 1,
        'revision': 'rev-1',
        'metadata': {'locale': 'en-IN'},
        'source': {
          'kind': 'json',
          'adapter': 'native_block_v1',
          'uri': 'cms://documents/doc',
        },
        'blocks': [
          {
            'id': 'p',
            'kind': 'paragraph',
            'children': [
              {'id': 'p.text', 'kind': 'text', 'text': 'Hello'},
            ],
          },
        ],
      });
    });

    test('round-trips table and callout JSON through adapter behavior', () {
      final json = {
        'id': 'doc',
        'schemaVersion': 1,
        'blocks': [
          {
            'id': 'callout',
            'kind': 'callout',
            'attributes': {'tone': 'info', 'variant': 'tip'},
            'children': [
              {
                'id': 'table',
                'kind': 'table',
                'children': [
                  {
                    'id': 'row',
                    'kind': 'tableRow',
                    'children': [
                      {
                        'id': 'cell',
                        'kind': 'tableCell',
                        'attributes': {'header': true, 'colSpan': 2},
                        'children': [
                          {'id': 'cell.text', 'kind': 'text', 'text': 'Status'},
                        ],
                      },
                    ],
                  },
                ],
              },
            ],
          },
        ],
      };

      final document = codec.decodeDocument(json);
      final encoded = codec.encodeDocument(document);
      final adapted = const TagflowNativeBlockAdapter().adapt(
        codec.decodeDocument(encoded),
      );

      final callout = adapted.nodeById('callout');
      expect(callout?.kind, TagflowNodeKind.container);
      expect(callout?.presentation.variant, 'tip');

      final cell = adapted.nodeById('cell');
      expect(cell?.kind, TagflowNodeKind.tableCell);
      expect(cell?.header, isTrue);
      expect(cell?.colSpan, 2);
      expect(cell?.children.single.text, 'Status');
    });

    test('decodes patch envelopes and applies through runtime patches', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(id: 'intro'),
          TagflowDocumentNode.container(
            id: 'section',
            children: [
              TagflowDocumentNode.paragraph(id: 'tail'),
              TagflowDocumentNode.paragraph(id: 'obsolete'),
            ],
          ),
        ],
      );

      final envelope = codec.decodePatchEnvelope({
        'id': 'doc',
        'schemaVersion': 1,
        'baseRevision': 'rev-1',
        'revision': 'rev-2',
        'operations': [
          {
            'op': 'replace',
            'nodeId': 'intro',
            'block': {
              'id': 'intro',
              'kind': 'heading',
              'attributes': {'level': 3},
              'children': [
                {'id': 'intro.text', 'kind': 'text', 'text': 'Updated'},
              ],
            },
          },
          {
            'op': 'append-children',
            'parentNodeId': 'section',
            'blocks': [
              {'id': 'append.a', 'kind': 'paragraph'},
              {'id': 'append.b', 'kind': 'paragraph'},
            ],
          },
          {
            'op': 'insert-before',
            'siblingNodeId': 'tail',
            'blocks': [
              {'id': 'inserted', 'kind': 'paragraph'},
            ],
          },
          {'op': 'remove', 'nodeId': 'obsolete'},
        ],
      });

      final patches = const TagflowNativeBlockAdapter().adaptPatches(
        envelope.operations,
      );
      final updated = document.applyPatches(patches);

      expect(envelope.documentId, 'doc');
      expect(envelope.baseRevision, 'rev-1');
      expect(envelope.revision, 'rev-2');
      expect(updated.children.first.kind, TagflowNodeKind.heading);
      expect(updated.children.first.children.single.text, 'Updated');
      expect(updated.children.last.children.map((node) => node.id), [
        'inserted',
        'tail',
        'append.a',
        'append.b',
      ]);
      expect(updated.containsNodeId('obsolete'), isFalse);
    });

    test('fails predictably for missing ids and unknown block kinds', () {
      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 1,
          'blocks': [
            {'kind': 'paragraph'},
          ],
        }),
        throwsFormatException,
      );

      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 1,
          'blocks': [
            {'id': 'x', 'kind': 'video'},
          ],
        }),
        throwsFormatException,
      );

      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 1,
          'blocks': [
            {'id': 'x'},
          ],
        }),
        throwsFormatException,
      );
    });

    test('rejects unsupported document schema versions', () {
      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 2,
          'blocks': const [],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('document.schemaVersion must be 1'),
          ),
        ),
      );

      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 0,
          'blocks': const [],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('document.schemaVersion must be greater than 0'),
          ),
        ),
      );
    });

    test('rejects unsupported patch envelope schema versions', () {
      expect(
        () => codec.decodePatchEnvelope({
          'id': 'doc',
          'schemaVersion': 2,
          'operations': const [],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('patch.schemaVersion must be 1'),
          ),
        ),
      );

      expect(
        () => codec.decodePatchEnvelope({
          'id': 'doc',
          'schemaVersion': 0,
          'operations': const [],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('patch.schemaVersion must be greater than 0'),
          ),
        ),
      );
    });

    test('fails predictably for unknown patch operations', () {
      expect(
        () => codec.decodePatchEnvelope({
          'id': 'doc',
          'schemaVersion': 1,
          'operations': [
            {'op': 'move', 'nodeId': 'x'},
          ],
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains(
              'Unknown native block patch operation "move" '
              'at patch.operations[0].op',
            ),
          ),
        ),
      );
    });

    test('rejects non JSON-like metadata and attributes', () {
      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 1,
          'metadata': {'callback': () {}},
          'blocks': const [],
        }),
        throwsFormatException,
      );

      expect(
        () => codec.decodeDocument({
          'id': 'doc',
          'schemaVersion': 1,
          'blocks': [
            {
              'id': 'x',
              'kind': 'paragraph',
              'attributes': {'builder': () {}},
            },
          ],
        }),
        throwsFormatException,
      );
    });
  });
}
