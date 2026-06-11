import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('Tagflow HTML adapter runtime entrypoints', () {
    testWidgets('render legacy, html, and document entrypoints equivalently', (
      tester,
    ) async {
      const html = '<p>Hello <strong>runtime</strong></p>';
      final document = const TagflowHtmlAdapter().parse(html);

      await tester.pumpWidget(const MaterialApp(home: Tagflow(html: html)));
      expect(find.textContaining('Hello runtime'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );
      expect(find.textContaining('Hello runtime'), findsOneWidget);

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));
      expect(find.textContaining('Hello runtime'), findsOneWidget);
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
