import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

TagflowDocumentNode _text(String id, String text) {
  return TagflowDocumentNode.text(id: id, text: text);
}

Future<void> _pump(WidgetTester tester, TagflowDocument document) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Tagflow.document(document))),
  );
}

void main() {
  group('typed node fields', () {
    test('should compare and copy checked and expanded', () {
      final item = TagflowDocumentNode.listItem(id: 'i', checked: true);
      final disclosure = TagflowDocumentNode.disclosure(
        id: 'd',
        expanded: true,
      );

      expect(item, TagflowDocumentNode.listItem(id: 'i', checked: true));
      expect(item, isNot(TagflowDocumentNode.listItem(id: 'i')));
      expect(item.copyWith(checked: false).checked, isFalse);
      expect(item.copyWith(clearChecked: true).checked, isNull);
      expect(
        () => item.copyWith(checked: true, clearChecked: true),
        throwsArgumentError,
      );
      expect(disclosure.copyWith(expanded: false).expanded, isFalse);
      expect(disclosure, isNot(TagflowDocumentNode.disclosure(id: 'd')));
      expect(TagflowDocumentNode.disclosure(id: 'd').expanded, isFalse);
    });

    test('should include display in presentation equality and merge', () {
      final inline = TagflowPresentation(display: TagflowDisplay.inline);

      expect(inline, TagflowPresentation(display: TagflowDisplay.inline));
      expect(inline, isNot(TagflowPresentation.empty));
      expect(inline.isEmpty, isFalse);
      expect(
        inline
            .merge(TagflowPresentation(display: TagflowDisplay.block))
            .display,
        TagflowDisplay.block,
      );
      expect(
        inline.merge(TagflowPresentation(variant: 'x')).display,
        inline.display,
      );
    });

    test('should keep typed fields across a patch of a child', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.disclosure(
            id: 'd',
            expanded: true,
            children: [_text('t', 'old')],
          ),
        ],
      );

      final patched = document.applyPatch(
        TagflowDocumentPatch.replaceNode(nodeId: 't', node: _text('t', 'new')),
      );

      expect(patched.children.single.kind, TagflowNodeKind.disclosure);
      expect(patched.children.single.expanded, isTrue);
    });
  });

  group('rendering without htmlTag', () {
    testWidgets('should render a hand-built disclosure and toggle it', (
      tester,
    ) async {
      await _pump(
        tester,
        TagflowDocument(
          id: 'doc',
          children: [
            TagflowDocumentNode.disclosure(
              id: 'd',
              children: [
                TagflowDocumentNode.disclosureSummary(
                  id: 's',
                  children: [_text('s.0', 'Offer details')],
                ),
                TagflowDocumentNode.paragraph(
                  id: 'p',
                  children: [_text('p.0', 'Issue size')],
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Offer details', findRichText: true), findsOneWidget);
      expect(find.text('Issue size', findRichText: true), findsNothing);

      await tester.tap(find.text('Offer details', findRichText: true));
      await tester.pump();

      expect(find.text('Issue size', findRichText: true), findsOneWidget);
    });

    testWidgets('should start an expanded disclosure open', (tester) async {
      await _pump(
        tester,
        TagflowDocument(
          id: 'doc',
          children: [
            TagflowDocumentNode.disclosure(
              id: 'd',
              expanded: true,
              children: [_text('d.0', 'Body')],
            ),
          ],
        ),
      );

      // No summary child: the title falls back to "Details".
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Body', findRichText: true), findsOneWidget);
    });

    testWidgets('should render a hand-built table caption above the rows', (
      tester,
    ) async {
      await _pump(
        tester,
        TagflowDocument(
          id: 'doc',
          children: [
            TagflowDocumentNode.table(
              id: 't',
              children: [
                TagflowDocumentNode.tableRow(
                  id: 'r',
                  children: [
                    TagflowDocumentNode.tableCell(
                      id: 'c',
                      children: [_text('c.0', 'Cell')],
                    ),
                  ],
                ),
                TagflowDocumentNode.tableCaption(
                  id: 'cap',
                  children: [_text('cap.0', 'Rates')],
                ),
              ],
            ),
          ],
        ),
      );

      final caption = tester.getTopLeft(find.text('Rates', findRichText: true));
      final cell = tester.getTopLeft(find.text('Cell', findRichText: true));
      expect(caption.dy, lessThan(cell.dy));
    });

    testWidgets('should mark task list items from checked', (tester) async {
      await _pump(
        tester,
        TagflowDocument(
          id: 'doc',
          children: [
            TagflowDocumentNode.list(
              id: 'l',
              ordered: false,
              children: [
                TagflowDocumentNode.listItem(
                  id: 'a',
                  checked: true,
                  children: [_text('a.0', 'done')],
                ),
                TagflowDocumentNode.listItem(
                  id: 'b',
                  checked: false,
                  children: [_text('b.0', 'open')],
                ),
                TagflowDocumentNode.listItem(
                  id: 'c',
                  children: [_text('c.0', 'plain')],
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('☑'), findsOneWidget);
      expect(find.text('☐'), findsOneWidget);
      expect(find.text('•'), findsOneWidget);
    });

    testWidgets('should flow an inline container with its paragraph', (
      tester,
    ) async {
      await _pump(
        tester,
        TagflowDocument(
          id: 'doc',
          children: [
            TagflowDocumentNode.paragraph(
              id: 'p',
              children: [
                _text('p.0', 'Hello '),
                TagflowDocumentNode.container(
                  id: 'p.1',
                  presentation: TagflowPresentation(
                    display: TagflowDisplay.inline,
                  ),
                  children: [_text('p.1.0', 'world')],
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Hello world', findRichText: true), findsOneWidget);
    });

    testWidgets('should ignore htmlTag hints when rendering', (tester) async {
      await _pump(
        tester,
        TagflowDocument(
          id: 'doc',
          children: [
            TagflowDocumentNode.container(
              id: 'fake',
              metadata: TagflowMetadata(const {'htmlTag': 'details'}),
              children: [_text('fake.0', 'Visible body')],
            ),
          ],
        ),
      );

      // A container is not a disclosure, whatever its provenance says.
      expect(find.text('Visible body', findRichText: true), findsOneWidget);
      expect(find.text('Details'), findsNothing);
    });
  });

  group('adapters', () {
    test('should set checked on Markdown task items', () {
      final document = const TagflowMarkdownAdapter().parse(
        '- [x] done\n- [ ] open\n- plain',
      );

      final items = document.children.single.children;
      expect(items.map((item) => item.checked), [true, false, null]);
      expect(items.first.markdownTaskChecked, isTrue);
      expect(items.last.isMarkdownTaskItem, isFalse);
    });

    test('should mark inline HTML elements with an inline display', () {
      final document = const TagflowHtmlAdapter().parse(
        '<p><span>a</span><kbd>b</kbd></p><div>c</div>',
      );

      final paragraph = document.children.first;
      expect(paragraph.children.map((node) => node.presentation.display), [
        TagflowDisplay.inline,
        TagflowDisplay.inline,
      ]);
      expect(paragraph.children.last.presentation.inlineSemantics, {
        TagflowInlineSemantic.code,
      });
      expect(document.children.last.presentation.display, isNull);
    });

    test('should round-trip typed native blocks through the codec', () {
      const codec = TagflowNativeBlockCodec();
      final document = TagflowNativeBlockDocument(
        id: 'doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.disclosure(
            id: 'd',
            expanded: true,
            children: [
              TagflowNativeBlock.disclosureSummary(
                id: 's',
                children: [TagflowNativeBlock.text(id: 's.t', text: 'Title')],
              ),
            ],
          ),
          TagflowNativeBlock.table(
            id: 't',
            children: [
              TagflowNativeBlock.tableCaption(
                id: 'cap',
                children: [TagflowNativeBlock.text(id: 'cap.t', text: 'Cap')],
              ),
            ],
          ),
          TagflowNativeBlock.list(
            id: 'l',
            ordered: false,
            children: [TagflowNativeBlock.listItem(id: 'i', checked: false)],
          ),
          TagflowNativeBlock.container(id: 'c', display: TagflowDisplay.inline),
        ],
      );

      final decoded = codec.decodeDocument(codec.encodeDocument(document));
      final adapted = const TagflowNativeBlockAdapter().adapt(decoded);

      final disclosure = adapted.children[0];
      expect(disclosure.kind, TagflowNodeKind.disclosure);
      expect(disclosure.expanded, isTrue);
      expect(
        disclosure.children.single.kind,
        TagflowNodeKind.disclosureSummary,
      );
      expect(
        adapted.children[1].children.single.kind,
        TagflowNodeKind.tableCaption,
      );
      expect(adapted.children[2].children.single.checked, isFalse);
      expect(adapted.children[3].presentation.display, TagflowDisplay.inline);
    });
  });
}
