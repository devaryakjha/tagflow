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
  });
}
