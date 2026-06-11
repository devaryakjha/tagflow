import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowNativeBlockAdapter', () {
    test('converts native block documents into runtime documents', () {
      final source = TagflowSourceInfo(
        kind: TagflowSourceKind.json,
        adapter: 'cms',
        uri: Uri.parse('cms://documents/announcement'),
      );
      final document = TagflowNativeBlockDocument(
        id: 'announcement',
        schemaVersion: 1,
        revision: 'rev-42',
        source: source,
        metadata: TagflowMetadata(const {'surface': 'detail'}),
        blocks: [
          TagflowNativeBlock.heading(
            id: 'title',
            level: 2,
            children: [
              TagflowNativeBlock.text(id: 'title-text', text: 'Launch day'),
            ],
          ),
          TagflowNativeBlock.paragraph(
            id: 'intro',
            children: [
              TagflowNativeBlock.text(id: 'intro-text', text: 'Read the '),
              TagflowNativeBlock.link(
                id: 'intro-link',
                url: 'https://example.com/guide',
                children: [
                  TagflowNativeBlock.text(id: 'link-text', text: 'guide'),
                ],
              ),
              TagflowNativeBlock.text(id: 'intro-tail', text: ' first.'),
            ],
          ),
          TagflowNativeBlock.list(
            id: 'steps',
            ordered: true,
            startIndex: 3,
            children: [
              TagflowNativeBlock.listItem(
                id: 'step-1',
                children: [
                  TagflowNativeBlock.text(id: 'step-1-text', text: 'Plan'),
                ],
              ),
              TagflowNativeBlock.listItem(
                id: 'step-2',
                children: [
                  TagflowNativeBlock.text(id: 'step-2-text', text: 'Ship'),
                ],
              ),
            ],
          ),
          TagflowNativeBlock.image(
            id: 'hero',
            url: 'https://example.com/hero.png',
            alt: 'Hero image',
            width: 640,
            height: 480,
          ),
        ],
      );

      final adapted = const TagflowNativeBlockAdapter().adapt(document);

      expect(adapted.id, 'announcement');
      expect(adapted.source, same(source));
      expect(adapted.metadata['surface'], 'detail');
      expect(adapted.metadata['revision'], 'rev-42');
      expect(adapted.metadata['schemaVersion'], 1);
      expect(adapted.children.map((node) => node.id), [
        'title',
        'intro',
        'steps',
        'hero',
      ]);

      final heading = adapted.children[0];
      expect(heading.kind, TagflowNodeKind.heading);
      expect(heading.id, 'title');
      expect(heading.level, 2);
      expect(heading.children.single.text, 'Launch day');

      final paragraph = adapted.children[1];
      expect(paragraph.kind, TagflowNodeKind.paragraph);
      expect(paragraph.children.map((node) => node.id), [
        'intro-text',
        'intro-link',
        'intro-tail',
      ]);

      final link = paragraph.children[1];
      expect(link.kind, TagflowNodeKind.link);
      expect(link.url, Uri.parse('https://example.com/guide'));
      expect(link.children.single.text, 'guide');

      final list = adapted.children[2];
      expect(list.kind, TagflowNodeKind.list);
      expect(list.ordered, isTrue);
      expect(list.startIndex, 3);
      expect(list.children.map((node) => node.id), ['step-1', 'step-2']);

      final image = adapted.children[3];
      expect(image.kind, TagflowNodeKind.image);
      expect(image.url, Uri.parse('https://example.com/hero.png'));
      expect(image.alt, 'Hero image');
      expect(image.width, 640);
      expect(image.height, 480);

      expect(adapted.nodeById('intro-link')?.id, 'intro-link');
      adapted.validateUniqueNodeIds();
    });

    test('preserves nested child order inside containers and blockquotes', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.container(
            id: 'wrapper',
            children: [
              TagflowNativeBlock.blockquote(
                id: 'quote',
                children: [
                  TagflowNativeBlock.paragraph(
                    id: 'quote-paragraph',
                    children: [
                      TagflowNativeBlock.text(id: 'a', text: 'alpha'),
                      TagflowNativeBlock.inlineCode(id: 'b', text: 'beta'),
                      TagflowNativeBlock.text(id: 'c', text: 'gamma'),
                    ],
                  ),
                ],
              ),
              TagflowNativeBlock.horizontalRule(id: 'divider'),
            ],
          ),
        ],
      );

      final adapted = const TagflowNativeBlockAdapter().adapt(document);
      final wrapper = adapted.children.single;

      expect(wrapper.kind, TagflowNodeKind.container);
      expect(wrapper.children.map((node) => node.id), ['quote', 'divider']);

      final quoteParagraph = wrapper.children.first.children.single;
      expect(quoteParagraph.children.map((node) => node.id), ['a', 'b', 'c']);
      expect(quoteParagraph.children.map((node) => node.kind), [
        TagflowNodeKind.text,
        TagflowNodeKind.inlineCode,
        TagflowNodeKind.text,
      ]);
    });

    test('adapts native tables into runtime table, row, and cell nodes', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock(
            id: 'pricing-table',
            kind: TagflowNativeBlockKind.table,
            children: [
              TagflowNativeBlock(
                id: 'header-row',
                kind: TagflowNativeBlockKind.tableRow,
                children: [
                  TagflowNativeBlock(
                    id: 'name-header',
                    kind: TagflowNativeBlockKind.tableCell,
                    attributes: const {
                      'header': true,
                      'rowSpan': 2,
                      'colSpan': 1,
                    },
                    children: [
                      TagflowNativeBlock.text(
                        id: 'name-header-text',
                        text: 'Name',
                      ),
                    ],
                  ),
                  TagflowNativeBlock(
                    id: 'price-header',
                    kind: TagflowNativeBlockKind.tableCell,
                    attributes: const {'header': true},
                    children: [
                      TagflowNativeBlock.text(
                        id: 'price-header-text',
                        text: 'Price',
                      ),
                    ],
                  ),
                ],
              ),
              TagflowNativeBlock(
                id: 'body-row',
                kind: TagflowNativeBlockKind.tableRow,
                children: [
                  TagflowNativeBlock(
                    id: 'name-cell',
                    kind: TagflowNativeBlockKind.tableCell,
                    children: [
                      TagflowNativeBlock.text(
                        id: 'name-cell-text',
                        text: 'Tagflow Pro',
                      ),
                    ],
                  ),
                  TagflowNativeBlock(
                    id: 'price-cell',
                    kind: TagflowNativeBlockKind.tableCell,
                    children: [
                      TagflowNativeBlock.text(
                        id: 'price-cell-text',
                        text: r'$29',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final adapted = const TagflowNativeBlockAdapter().adapt(document);
      final table = adapted.children.single;

      expect(table.kind, TagflowNodeKind.table);
      expect(table.id, 'pricing-table');
      expect(table.children.map((node) => node.id), ['header-row', 'body-row']);

      final headerRow = table.children.first;
      expect(headerRow.kind, TagflowNodeKind.tableRow);
      expect(headerRow.children.map((node) => node.id), [
        'name-header',
        'price-header',
      ]);

      final headerCell = headerRow.children.first;
      expect(headerCell.kind, TagflowNodeKind.tableCell);
      expect(headerCell.header, isTrue);
      expect(headerCell.rowSpan, 2);
      expect(headerCell.colSpan, 1);
      expect(headerCell.children.single.text, 'Name');

      final bodyRow = table.children.last;
      expect(bodyRow.kind, TagflowNodeKind.tableRow);
      expect(bodyRow.children.map((node) => node.id), [
        'name-cell',
        'price-cell',
      ]);
      expect(bodyRow.children.last.children.single.text, r'$29');

      expect(adapted.nodeById('price-cell')?.kind, TagflowNodeKind.tableCell);
    });

    test('keeps non-semantic table attributes as metadata without widening '
        'runtime fields', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock(
            id: 'table',
            kind: TagflowNativeBlockKind.table,
            attributes: const {'caption': 'Pricing'},
            children: [
              TagflowNativeBlock(
                id: 'row',
                kind: TagflowNativeBlockKind.tableRow,
                children: [
                  TagflowNativeBlock(
                    id: 'cell',
                    kind: TagflowNativeBlockKind.tableCell,
                    attributes: const {
                      'header': true,
                      'rowSpan': 3,
                      'colSpan': 2,
                      'alignment': 'right',
                      'scope': 'col',
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final adapted = const TagflowNativeBlockAdapter().adapt(document);
      final table = adapted.children.single;
      final cell = table.children.single.children.single;

      expect(table.kind, TagflowNodeKind.table);
      expect(table.metadata['blockAttributes'], const {'caption': 'Pricing'});
      expect(cell.kind, TagflowNodeKind.tableCell);
      expect(cell.header, isTrue);
      expect(cell.rowSpan, 3);
      expect(cell.colSpan, 2);
      expect(cell.metadata['blockAttributes'], const {
        'header': true,
        'rowSpan': 3,
        'colSpan': 2,
        'alignment': 'right',
        'scope': 'col',
      });
    });

    test('fails when duplicate block ids are present', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.paragraph(id: 'duplicate'),
          TagflowNativeBlock.container(
            id: 'section',
            children: [TagflowNativeBlock.text(id: 'duplicate', text: 'boom')],
          ),
        ],
      );

      expect(
        () => const TagflowNativeBlockAdapter().adapt(document),
        throwsStateError,
      );
    });

    test('fails when a required block id is blank', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [TagflowNativeBlock.paragraph(id: ' ')],
      );

      expect(
        () => const TagflowNativeBlockAdapter().adapt(document),
        throwsArgumentError,
      );
    });

    test('fails when typed document schema version is unsupported', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 2,
        blocks: const [],
      );

      expect(
        () => const TagflowNativeBlockAdapter().adapt(document),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('Native block schemaVersion must be 1'),
          ),
        ),
      );
    });

    test('normalizes callout blocks to container nodes predictably', () {
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock(
            id: 'callout',
            kind: TagflowNativeBlockKind.callout,
            attributes: const {
              'tone': 'info',
              'variant': 'tip',
              'title': 'What changed',
            },
            children: [
              TagflowNativeBlock.paragraph(
                id: 'callout-paragraph',
                children: [
                  TagflowNativeBlock.text(
                    id: 'callout-text',
                    text: 'Orders now settle next business day.',
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final adapted = const TagflowNativeBlockAdapter().adapt(document);
      final callout = adapted.children.single;

      expect(callout.kind, TagflowNodeKind.container);
      expect(callout.id, 'callout');
      expect(callout.presentation.variant, 'tip');
      expect(callout.metadata['blockKind'], 'callout');
      expect(callout.metadata['blockAttributes'], const {
        'tone': 'info',
        'variant': 'tip',
        'title': 'What changed',
      });
      expect(callout.children.single.id, 'callout-paragraph');
      expect(callout.children.single.children.single.text, contains('settle'));
    });

    test('uses content policy for link and image urls', () {
      const adapter = TagflowNativeBlockAdapter(
        policy: TagflowContentPolicy(
          allowRelativeUrls: false,
          allowRemoteImages: false,
          unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
        ),
      );
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.paragraph(
            id: 'paragraph',
            children: [
              TagflowNativeBlock.link(
                id: 'relative-link',
                url: '/relative-path',
                children: [
                  TagflowNativeBlock.text(id: 'link-text', text: 'relative'),
                ],
              ),
            ],
          ),
          TagflowNativeBlock.image(
            id: 'remote-image',
            url: 'https://example.com/blocked.png',
          ),
        ],
      );

      final adapted = adapter.adapt(document);
      final link = adapted.children.first.children.single;

      expect(link.kind, TagflowNodeKind.container);
      expect(link.metadata['policyDecisionReason'], 'relativeUrlNotAllowed');

      final image = adapted.nodeById('remote-image');
      expect(image?.kind, TagflowNodeKind.unsupported);
      expect(image?.unsupportedReason, contains('rejected by policy'));
    });

    test('drops policy-rejected native image blocks by default', () {
      const adapter = TagflowNativeBlockAdapter(
        policy: TagflowContentPolicy(allowRemoteImages: false),
      );
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.image(
            id: 'remote-image',
            url: 'https://example.com/blocked.png',
          ),
        ],
      );

      final adapted = adapter.adapt(document);

      expect(adapted.nodeById('remote-image'), isNull);
      expect(adapted.children, isEmpty);
    });
  });
}
