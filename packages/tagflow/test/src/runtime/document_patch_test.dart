import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowDocumentPatch', () {
    test('replaces an existing node immutably', () {
      final unchanged = TagflowDocumentNode.paragraph(
        id: 'tail',
        children: [TagflowDocumentNode.text(id: 'tail.text', text: 'Tail')],
      );
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'intro',
            children: [TagflowDocumentNode.text(id: 'intro.text', text: 'Old')],
          ),
          unchanged,
        ],
      );
      final replacement = TagflowDocumentNode.heading(
        id: 'intro',
        level: 2,
        children: [TagflowDocumentNode.text(id: 'intro.text.new', text: 'New')],
      );

      final updated = document.applyPatch(
        TagflowDocumentPatch.replaceNode(nodeId: 'intro', node: replacement),
      );

      expect(updated, isNot(same(document)));
      expect(updated.children.first, same(replacement));
      expect(updated.children.last, same(unchanged));
      expect(document.children.first.kind, TagflowNodeKind.paragraph);
    });

    test('appends children to an existing parent immutably', () {
      final existingItem = TagflowDocumentNode.listItem(
        id: 'list.item.1',
        children: [
          TagflowDocumentNode.text(id: 'list.item.1.text', text: 'One'),
        ],
      );
      final untouched = TagflowDocumentNode.paragraph(id: 'after');
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.list(
            id: 'list',
            ordered: false,
            children: [existingItem],
          ),
          untouched,
        ],
      );
      final appended = TagflowDocumentNode.listItem(
        id: 'list.item.2',
        children: [
          TagflowDocumentNode.text(id: 'list.item.2.text', text: 'Two'),
        ],
      );

      final updated = document.applyPatch(
        TagflowDocumentPatch.appendChildren(
          parentNodeId: 'list',
          children: [appended],
        ),
      );

      final updatedList = updated.children.first;
      expect(updatedList.children, [existingItem, appended]);
      expect(updatedList.children.first, same(existingItem));
      expect(updated.children.last, same(untouched));
      expect(document.children.first.children, [existingItem]);
    });

    test('removes an existing node immutably', () {
      final first = TagflowDocumentNode.paragraph(id: 'first');
      final removed = TagflowDocumentNode.paragraph(id: 'remove');
      final last = TagflowDocumentNode.paragraph(id: 'last');
      final document = TagflowDocument(
        id: 'doc',
        children: [first, removed, last],
      );

      final updated = document.applyPatch(
        const TagflowDocumentPatch.removeNode(nodeId: 'remove'),
      );

      expect(updated.children, [first, last]);
      expect(updated.children.first, same(first));
      expect(updated.children.last, same(last));
      expect(document.children, [first, removed, last]);
    });

    test('applies multiple patches in order', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.container(id: 'section')],
      );
      final child = TagflowDocumentNode.paragraph(id: 'section.child');
      final intro = TagflowDocumentNode.paragraph(id: 'section.intro');

      final updated = document.applyPatches([
        TagflowDocumentPatch.appendChildren(
          parentNodeId: 'section',
          children: [child],
        ),
        TagflowDocumentPatch.insertBefore(
          siblingNodeId: 'section.child',
          nodes: [intro],
        ),
      ]);

      expect(updated.children.single.children, [intro, child]);
    });

    test('inserts nodes before a root-level sibling immutably', () {
      final first = TagflowDocumentNode.paragraph(id: 'first');
      final sibling = TagflowDocumentNode.paragraph(id: 'sibling');
      final tail = TagflowDocumentNode.paragraph(id: 'tail');
      final inserted = TagflowDocumentNode.paragraph(id: 'inserted');
      final document = TagflowDocument(
        id: 'doc',
        children: [first, sibling, tail],
      );

      final updated = document.applyPatch(
        TagflowDocumentPatch.insertBefore(
          siblingNodeId: 'sibling',
          nodes: [inserted],
        ),
      );

      expect(updated.children, [first, inserted, sibling, tail]);
      expect(updated.children.first, same(first));
      expect(updated.children[2], same(sibling));
      expect(updated.children.last, same(tail));
      expect(document.children, [first, sibling, tail]);
    });

    test(
      'inserts nodes before a nested sibling and reuses untouched branches',
      () {
        final leading = TagflowDocumentNode.paragraph(id: 'leading');
        final nestedSibling = TagflowDocumentNode.paragraph(id: 'target');
        final trailing = TagflowDocumentNode.paragraph(id: 'trailing');
        final section = TagflowDocumentNode.container(
          id: 'section',
          children: [leading, nestedSibling, trailing],
        );
        final untouchedBranch = TagflowDocumentNode.container(
          id: 'aside',
          children: [TagflowDocumentNode.paragraph(id: 'aside.copy')],
        );
        final inserted = TagflowDocumentNode.paragraph(id: 'inserted');
        final document = TagflowDocument(
          id: 'doc',
          children: [section, untouchedBranch],
        );

        final updated = document.applyPatch(
          TagflowDocumentPatch.insertBefore(
            siblingNodeId: 'target',
            nodes: [inserted],
          ),
        );

        final updatedSection = updated.children.first;
        expect(updatedSection.children, [
          leading,
          inserted,
          nestedSibling,
          trailing,
        ]);
        expect(updatedSection.children.first, same(leading));
        expect(updatedSection.children[2], same(nestedSibling));
        expect(updatedSection.children.last, same(trailing));
        expect(updated.children.last, same(untouchedBranch));
        expect(document.children.first.children, [
          leading,
          nestedSibling,
          trailing,
        ]);
      },
    );

    test('fails when the target node is missing', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'known')],
      );

      expect(
        () => document.applyPatch(
          const TagflowDocumentPatch.removeNode(nodeId: 'missing'),
        ),
        throwsArgumentError,
      );
    });

    test('fails when insert-before sibling is missing', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'known')],
      );

      expect(
        () => document.applyPatch(
          TagflowDocumentPatch.insertBefore(
            siblingNodeId: 'missing',
            nodes: [TagflowDocumentNode.paragraph(id: 'inserted')],
          ),
        ),
        throwsArgumentError,
      );
    });

    test('fails when a patch introduces duplicate node ids', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.container(id: 'section'),
          TagflowDocumentNode.paragraph(id: 'existing'),
        ],
      );

      expect(
        () => document.applyPatch(
          TagflowDocumentPatch.appendChildren(
            parentNodeId: 'section',
            children: [TagflowDocumentNode.paragraph(id: 'existing')],
          ),
        ),
        throwsStateError,
      );
    });

    test('fails when insert-before introduces duplicate node ids', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(id: 'existing'),
          TagflowDocumentNode.paragraph(id: 'sibling'),
        ],
      );

      expect(
        () => document.applyPatch(
          TagflowDocumentPatch.insertBefore(
            siblingNodeId: 'sibling',
            nodes: [TagflowDocumentNode.paragraph(id: 'existing')],
          ),
        ),
        throwsStateError,
      );
    });

    test('fails when the existing document has duplicate node ids', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(id: 'duplicate'),
          TagflowDocumentNode.paragraph(id: 'duplicate'),
        ],
      );

      expect(
        () => document.applyPatch(
          TagflowDocumentPatch.insertBefore(
            siblingNodeId: 'duplicate',
            nodes: [TagflowDocumentNode.paragraph(id: 'inserted')],
          ),
        ),
        throwsStateError,
      );
    });

    test('fails when replacement node id does not match target id', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'target')],
      );

      expect(
        () => document.applyPatch(
          TagflowDocumentPatch.replaceNode(
            nodeId: 'target',
            node: TagflowDocumentNode.paragraph(id: 'different'),
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
