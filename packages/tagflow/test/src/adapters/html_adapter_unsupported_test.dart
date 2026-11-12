import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

const _html = '''
<p>Hello<span></span> world<wbr>x</p>
<video src="a.mp4"></video>
<x-widget></x-widget>
''';

const _placeholderPolicy = TagflowContentPolicy(
  unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
);

Iterable<TagflowDocumentNode> _walk(Iterable<TagflowDocumentNode> nodes) sync* {
  for (final node in nodes) {
    yield node;
    yield* _walk(node.children);
  }
}

void main() {
  group('HTML adapter unsupported content', () {
    test('should map span to an inline container', () {
      final document = const TagflowHtmlAdapter().parse(
        '<p>a <span>b</span></p>',
      );
      final span = _walk(
        document.children,
      ).firstWhere((node) => node.htmlTag == 'span');

      expect(span.kind, TagflowNodeKind.container);
    });

    test('should map wbr to a zero-width space', () {
      final document = const TagflowHtmlAdapter().parse('<p>a<wbr>b</p>');
      final texts = _walk(
        document.children,
      ).where((node) => node.kind == TagflowNodeKind.text).map((n) => n.text);

      expect(texts, ['a', '​', 'b']);
    });

    test('should drop childless unsupported nodes under the drop policy', () {
      final document = const TagflowHtmlAdapter().parse(_html);

      expect(
        _walk(
          document.children,
        ).where((node) => node.kind == TagflowNodeKind.unsupported),
        isEmpty,
      );
    });

    test('should keep unknown elements that have children', () {
      final document = const TagflowHtmlAdapter().parse(
        '<x-card><p>Still here</p></x-card>',
      );

      expect(document.children.single.kind, TagflowNodeKind.unsupported);
      expect(document.children.single.children, isNotEmpty);
    });

    test('should keep placeholders under preservePlaceholder', () {
      final document = const TagflowHtmlAdapter(
        policy: _placeholderPolicy,
      ).parse(_html);
      final unsupported = _walk(document.children)
          .where((node) => node.kind == TagflowNodeKind.unsupported)
          .map((node) => node.htmlTag);

      expect(unsupported, containsAll(<String>['video', 'x-widget']));
      expect(unsupported, isNot(contains('span')));
      expect(unsupported, isNot(contains('wbr')));
    });

    testWidgets('should not show a placeholder under the default policy', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Tagflow.html(html: _html)),
        ),
      );

      expect(find.text('Unsupported content'), findsNothing);
      expect(find.textContaining('Hello'), findsOneWidget);
    });

    testWidgets('should show placeholders under preservePlaceholder', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Tagflow.html(
              html: _html,
              adapter: TagflowHtmlAdapter(policy: _placeholderPolicy),
            ),
          ),
        ),
      );

      expect(find.text('Unsupported content'), findsNWidgets(2));
    });

    test('should drop childless unsupported Markdown nodes', () {
      final document = const TagflowMarkdownAdapter().parse(
        'Hello <video src="a.mp4"></video> world',
      );

      expect(
        _walk(
          document.children,
        ).where((node) => node.kind == TagflowNodeKind.unsupported),
        isEmpty,
      );
    });
  });
}
