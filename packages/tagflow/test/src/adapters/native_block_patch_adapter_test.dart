import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowNativeBlockPatch adaptation', () {
    test('adapts replacement updates into runtime patches', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'intro',
            children: [TagflowDocumentNode.text(id: 'intro.text', text: 'Old')],
          ),
          TagflowDocumentNode.paragraph(id: 'tail'),
        ],
      );
      const adapter = TagflowNativeBlockAdapter();

      final patch = adapter.adaptPatch(
        TagflowNativeBlockPatch.replaceNode(
          nodeId: 'intro',
          block: TagflowNativeBlock.heading(
            id: 'intro',
            level: 2,
            children: [
              TagflowNativeBlock.text(id: 'intro.heading', text: 'New'),
            ],
          ),
        ),
      );
      final updated = document.applyPatch(patch);

      final intro = updated.children.first;
      expect(intro.kind, TagflowNodeKind.heading);
      expect(intro.level, 2);
      expect(intro.children.single.id, 'intro.heading');
      expect(intro.children.single.text, 'New');
      expect(updated.children.last.id, 'tail');
    });

    test('adapts append updates preserving child order and ids', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.container(
            id: 'section',
            children: [TagflowDocumentNode.paragraph(id: 'existing')],
          ),
        ],
      );
      const adapter = TagflowNativeBlockAdapter();

      final patch = adapter.adaptPatch(
        TagflowNativeBlockPatch.appendChildren(
          parentNodeId: 'section',
          children: [
            TagflowNativeBlock.paragraph(id: 'second'),
            TagflowNativeBlock.paragraph(id: 'third'),
          ],
        ),
      );
      final updated = document.applyPatch(patch);

      expect(updated.children.single.children.map((node) => node.id), [
        'existing',
        'second',
        'third',
      ]);
    });

    test('adapts insert-before updates through ordered runtime insertion', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.container(
            id: 'section',
            children: [
              TagflowDocumentNode.paragraph(id: 'before'),
              TagflowDocumentNode.paragraph(id: 'target'),
            ],
          ),
        ],
      );
      const adapter = TagflowNativeBlockAdapter();

      final patch = adapter.adaptPatch(
        TagflowNativeBlockPatch.insertBefore(
          siblingNodeId: 'target',
          nodes: [
            TagflowNativeBlock.paragraph(id: 'inserted-a'),
            TagflowNativeBlock.paragraph(id: 'inserted-b'),
          ],
        ),
      );
      final updated = document.applyPatch(patch);

      expect(updated.children.single.children.map((node) => node.id), [
        'before',
        'inserted-a',
        'inserted-b',
        'target',
      ]);
    });

    test('adapts remove updates into runtime remove patches', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(id: 'keep'),
          TagflowDocumentNode.paragraph(id: 'remove'),
          TagflowDocumentNode.paragraph(id: 'tail'),
        ],
      );
      const adapter = TagflowNativeBlockAdapter();

      final patch = adapter.adaptPatch(
        const TagflowNativeBlockPatch.removeNode(nodeId: 'remove'),
      );
      final updated = document.applyPatch(patch);

      expect(updated.children.map((node) => node.id), ['keep', 'tail']);
    });

    test('adapts callout and table blocks through patch updates', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.container(id: 'section')],
      );
      const adapter = TagflowNativeBlockAdapter();

      final patch = adapter.adaptPatch(
        TagflowNativeBlockPatch.appendChildren(
          parentNodeId: 'section',
          children: [
            TagflowNativeBlock.callout(
              id: 'callout',
              variant: 'tip',
              children: [
                TagflowNativeBlock.table(
                  id: 'table',
                  children: [
                    TagflowNativeBlock.tableRow(
                      id: 'row',
                      children: [
                        TagflowNativeBlock.tableCell(
                          id: 'cell',
                          header: true,
                          children: [
                            TagflowNativeBlock.text(
                              id: 'cell.text',
                              text: 'Status',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
      final updated = document.applyPatch(patch);

      final callout = updated.nodeById('callout');
      expect(callout?.kind, TagflowNodeKind.container);
      expect(callout?.presentation.variant, 'tip');

      final table = updated.nodeById('table');
      expect(table?.kind, TagflowNodeKind.table);
      expect(table?.children.single.kind, TagflowNodeKind.tableRow);
      expect(
        table?.children.single.children.single.kind,
        TagflowNodeKind.tableCell,
      );
      expect(
        table?.children.single.children.single.children.single.text,
        'Status',
      );
    });

    test(
      'fails on duplicate ids in appended payloads before patch application',
      () {
        const adapter = TagflowNativeBlockAdapter();

        expect(
          () => adapter.adaptPatch(
            TagflowNativeBlockPatch.appendChildren(
              parentNodeId: 'section',
              children: [
                TagflowNativeBlock.paragraph(id: 'duplicate'),
                TagflowNativeBlock.container(
                  id: 'wrapper',
                  children: [
                    TagflowNativeBlock.text(id: 'duplicate', text: 'x'),
                  ],
                ),
              ],
            ),
          ),
          throwsStateError,
        );
      },
    );

    test('fails when replacement block id does not match the target id', () {
      const adapter = TagflowNativeBlockAdapter();

      expect(
        () => adapter.adaptPatch(
          TagflowNativeBlockPatch.replaceNode(
            nodeId: 'expected',
            block: TagflowNativeBlock.paragraph(id: 'different'),
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
