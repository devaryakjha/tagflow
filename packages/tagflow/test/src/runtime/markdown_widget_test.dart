import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('Tagflow.markdown', () {
    testWidgets('renders GFM through the semantic runtime', (tester) async {
      const markdown =
          '# Answer\n\n'
          'Use **bold** and `code`.\n\n'
          '- [x] shipped\n- [ ] pending\n\n'
          '```dart\nvoid main() {}\n```\n\n'
          '| Name | Value |\n|---|---|\n| a | 1 |';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Tagflow.markdown(markdown: markdown)),
        ),
      );

      expect(find.text('Answer'), findsOneWidget);
      expect(find.text('bold'), findsOneWidget);
      expect(find.text('code'), findsOneWidget);
      expect(find.text('☑'), findsOneWidget);
      expect(find.text('☐'), findsOneWidget);
      expect(find.text('void main() {}'), findsOneWidget);
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Value'), findsOneWidget);
    });

    testWidgets('keys rendered nodes by deterministic markdown ids', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.markdown(markdown: '# A\n\nB')),
      );

      expect(find.byKey(const ValueKey<String>('0.0')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('0.1')), findsOneWidget);
    });

    testWidgets('re-adapts when markdown or adapter changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.markdown(markdown: 'Hi <b>there</b>')),
      );
      expect(find.text('there'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Tagflow.markdown(
            markdown: 'Hi <b>there</b>',
            markdownAdapter: TagflowMarkdownAdapter(
              rawHtml: TagflowMarkdownRawHtmlBehavior.text,
            ),
          ),
        ),
      );
      expect(find.text('<b>'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.markdown(markdown: 'Updated')),
      );
      expect(find.text('Updated'), findsOneWidget);
    });

    testWidgets('uses custom component registries', (tester) async {
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.heading: (context, node) =>
              Text('custom ${node.level}'),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.markdown(markdown: '## Title', registry: registry),
        ),
      );

      expect(find.text('custom 2'), findsOneWidget);
    });

    testWidgets('invokes link tap callbacks for markdown links', (
      tester,
    ) async {
      String? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.markdown(
            markdown: '[docs](https://docs.arya.run)',
            viewOptions: TagflowViewOptions(
              linkTapCallback: (url, attributes) => tapped = url,
            ),
          ),
        ),
      );

      await tester.tap(find.text('docs'));
      expect(tapped, 'https://docs.arya.run');
    });
  });
}
