import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('Tagflow HTML adapter runtime entrypoints', () {
    testWidgets('legacy and html entrypoints render existing HTML cases', (
      tester,
    ) async {
      const html = '<p>Hello <strong>runtime</strong></p>';

      await tester.pumpWidget(const MaterialApp(home: Tagflow(html: html)));
      expect(find.textContaining('Hello runtime'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );
      expect(find.textContaining('Hello runtime'), findsOneWidget);
    });

    testWidgets('document entrypoint renders semantic paragraph content', (
      tester,
    ) async {
      final document = _documentWithParagraph('Native runtime');

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            converters: const [_LegacyParagraphConverter()],
          ),
        ),
      );

      expect(find.text('Native runtime'), findsOneWidget);
      expect(find.text('Legacy bridge'), findsNothing);
    });

    testWidgets('document entrypoint uses registry overrides', (tester) async {
      final document = _documentWithParagraph('Built-in runtime');
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            return const Text('Registry paragraph');
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(document, registry: registry)),
      );

      expect(find.text('Registry paragraph'), findsOneWidget);
      expect(find.text('Built-in runtime'), findsNothing);
    });

    testWidgets('selectable wrapping applies around semantic content', (
      tester,
    ) async {
      final document = _documentWithParagraph('Selectable runtime');

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            options: TagflowOptions.defaults.copyWith(
              selectable: const TagflowSelectableOptions(enabled: true),
            ),
          ),
        ),
      );

      expect(find.byType(SelectionArea), findsOneWidget);
      expect(find.text('Selectable runtime'), findsOneWidget);
    });

    test('adapts HTML into a source-tagged runtime document', () {
      const html = '<h2>Title</h2><p>Body</p>';
      final document = const TagflowHtmlAdapter().parse(html);

      expect(document.source?.kind, TagflowSourceKind.html);
      expect(document.source?.adapter, 'html');
      expect(document.children, hasLength(2));
      expect(document.children.first.kind, TagflowNodeKind.heading);
      expect(document.children.first.level, 2);
      expect(document.children.last.kind, TagflowNodeKind.paragraph);
    });

    test('drops blocked elements with the default content policy', () {
      const html =
          '<p>Safe</p><script>alert(1)</script><iframe src="/x"></iframe>';
      final document = const TagflowHtmlAdapter().parse(html);

      expect(document.children, hasLength(1));
      expect(document.children.single.kind, TagflowNodeKind.paragraph);
      expect(_flattenText(document.children), isNot(contains('alert')));
    });

    test('preserves blocked elements as placeholders when configured', () {
      const adapter = TagflowHtmlAdapter(
        policy: TagflowContentPolicy(
          unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
        ),
      );

      final document = adapter.parse('<div><script>alert(1)</script></div>');
      final placeholders = _findNodesInDocument(
        document,
        TagflowNodeKind.unsupported,
      );

      expect(placeholders, hasLength(1));
      expect(placeholders.single.children, isEmpty);
      expect(
        placeholders.single.unsupportedReason,
        contains('rejected by policy'),
      );
    });

    test('rejects unsafe link URLs while preserving link text', () {
      const html = '<p>Tap <a href="javascript:alert(1)">here</a></p>';
      final document = const TagflowHtmlAdapter().parse(html);
      final paragraph = document.children.single;

      expect(_findNodes(paragraph, TagflowNodeKind.link), isEmpty);
      expect(_flattenText([paragraph]), contains('Tap here'));
    });

    test('drops images when resource policy rejects the source URL', () {
      const adapter = TagflowHtmlAdapter(
        policy: TagflowContentPolicy(allowRemoteImages: false),
      );

      final document = adapter.parse(
        '<p>Before</p><img src="https://example.com/image.png" alt="Remote">',
      );

      expect(_findNodesInDocument(document, TagflowNodeKind.image), isEmpty);
      expect(_flattenText(document.children), contains('Before'));
    });

    test(
      'preserved rejected image placeholders do not bridge back to images',
      () {
        const adapter = TagflowHtmlAdapter(
          policy: TagflowContentPolicy(
            allowRemoteImages: false,
            unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
          ),
        );

        final document = adapter.parse(
          '<img src="https://example.com/image.png" alt="Remote">',
        );
        final legacyNode = TagflowHtmlDocumentBridge.toLegacyNode(document);

        expect(_findNodesInDocument(document, TagflowNodeKind.image), isEmpty);
        expect(_findLegacyTags(legacyNode, 'img'), isEmpty);
      },
    );
  });
}

final class _LegacyParagraphConverter extends ElementConverter<TagflowNode> {
  const _LegacyParagraphConverter();

  @override
  Set<String> get supportedTags => {'p'};

  @override
  Widget convert(
    TagflowNode element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    return const Text('Legacy bridge');
  }
}

TagflowDocument _documentWithParagraph(String text) {
  return TagflowDocument(
    id: 'doc',
    children: [
      TagflowDocumentNode.paragraph(
        id: 'p1',
        children: [TagflowDocumentNode.text(id: 't1', text: text)],
      ),
    ],
  );
}

String _flattenText(List<TagflowDocumentNode> nodes) {
  final buffer = StringBuffer();
  void visit(TagflowDocumentNode node) {
    if (node.text != null) buffer.write(node.text);
    for (final child in node.children) {
      visit(child);
    }
  }

  for (final node in nodes) {
    visit(node);
  }
  return buffer.toString();
}

List<TagflowDocumentNode> _findNodesInDocument(
  TagflowDocument document,
  TagflowNodeKind kind,
) {
  return [for (final child in document.children) ..._findNodes(child, kind)];
}

List<TagflowDocumentNode> _findNodes(
  TagflowDocumentNode node,
  TagflowNodeKind kind,
) {
  return [
    if (node.kind == kind) node,
    for (final child in node.children) ..._findNodes(child, kind),
  ];
}

List<TagflowNode> _findLegacyTags(TagflowNode node, String tag) {
  return [
    if (node.tag == tag) node,
    for (final child in node.children) ..._findLegacyTags(child, tag),
  ];
}
