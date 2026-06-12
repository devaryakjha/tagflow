import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

void main() {
  group('Tagflow HTML adapter runtime entrypoints', () {
    testWidgets('legacy and html entrypoints render existing HTML cases', (
      tester,
    ) async {
      const html = '<p>Hello <strong>runtime</strong></p>';

      await tester.pumpWidget(const MaterialApp(home: Tagflow(html: html)));
      expect(find.text('Hello '), findsOneWidget);
      expect(find.text('runtime'), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );
      expect(find.text('Hello '), findsOneWidget);
      expect(find.text('runtime'), findsOneWidget);
    });

    testWidgets('html entrypoints render built-ins through semantic runtime', (
      tester,
    ) async {
      const html = '<p>Semantic runtime</p>';

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );

      expect(_textWidgetWithData('Semantic runtime'), findsOneWidget);
      expect(_textWidgetWithSpan('Semantic runtime'), findsNothing);

      await tester.pumpWidget(const MaterialApp(home: Tagflow(html: html)));

      expect(_textWidgetWithData('Semantic runtime'), findsOneWidget);
      expect(_textWidgetWithSpan('Semantic runtime'), findsNothing);
    });

    testWidgets('html entrypoint renders inline semantic presentation', (
      tester,
    ) async {
      const html =
          '<p><strong>Bold</strong> <em>Italic</em> <mark>Marked</mark></p>';

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );

      expect(find.text('Bold'), findsOneWidget);
      expect(find.text('Italic'), findsOneWidget);
      expect(find.text('Marked'), findsOneWidget);
      expect(_richTextStyle(tester, 'Bold')?.fontWeight, FontWeight.w700);
      expect(_richTextStyle(tester, 'Italic')?.fontStyle, FontStyle.italic);
      expect(
        find.ancestor(
          of: find.text('Marked'),
          matching: find.byType(DecoratedBox),
        ),
        findsWidgets,
      );
    });

    testWidgets('html entrypoint renders table captions through built-ins', (
      tester,
    ) async {
      const html = '''
<table>
  <caption>Revenue summary</caption>
  <tr><td>Q1</td></tr>
</table>
''';

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );

      expect(find.byType(Table), findsOneWidget);
      expect(find.text('Revenue summary'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Revenue summary')).dy,
        lessThan(tester.getTopLeft(find.byType(Table)).dy),
      );
    });

    testWidgets(
      'html entrypoint renders details as an interactive disclosure',
      (tester) async {
        const html = '''
<details>
  <summary>Read more</summary>
  <p>Hidden body</p>
</details>
''';

        await tester.pumpWidget(
          const MaterialApp(home: Tagflow.html(html: html)),
        );

        expect(find.text('Read more'), findsOneWidget);
        expect(find.text('Hidden body'), findsNothing);

        await tester.tap(find.text('Read more'));
        await tester.pump();

        expect(find.text('Hidden body'), findsOneWidget);

        await tester.tap(find.text('Read more'));
        await tester.pump();

        expect(find.text('Hidden body'), findsNothing);
      },
    );

    testWidgets('html entrypoint respects open details by default', (
      tester,
    ) async {
      const html = '''
<details open>
  <summary>Already open</summary>
  <p>Visible body</p>
</details>
''';

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );

      expect(find.text('Already open'), findsOneWidget);
      expect(find.text('Visible body'), findsOneWidget);
    });

    testWidgets('details without summary uses a fallback disclosure title', (
      tester,
    ) async {
      const html = '<details><p>Fallback body</p></details>';

      await tester.pumpWidget(
        const MaterialApp(home: Tagflow.html(html: html)),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Fallback body'), findsNothing);

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('Fallback body'), findsOneWidget);
    });

    testWidgets('custom legacy converters keep compatibility path', (
      tester,
    ) async {
      const html = '<p>Built-in paragraph</p>';

      await tester.pumpWidget(
        const MaterialApp(
          home: Tagflow.html(
            html: html,
            converters: [_LegacyParagraphConverter()],
          ),
        ),
      );

      expect(find.text('Legacy bridge'), findsOneWidget);
      expect(find.text('Built-in paragraph'), findsNothing);
    });

    testWidgets('custom legacy converter errors use the widget error builder', (
      tester,
    ) async {
      const html = '<p>Built-in paragraph</p>';

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.html(
            html: html,
            converters: const [_ThrowingLegacyParagraphConverter()],
            errorBuilder: (context, error) {
              return Text('Legacy error: $error');
            },
          ),
        ),
      );

      expect(
        find.textContaining('Legacy error: Bad state: legacy failed'),
        findsOneWidget,
      );
      expect(find.text('Built-in paragraph'), findsNothing);
    });

    testWidgets('parse errors keep using the widget error builder', (
      tester,
    ) async {
      const html = '<div data-tagflow-id="root"><hr></div>';

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.html(
            html: html,
            adapter: const TagflowHtmlAdapter(
              nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(
                fallbackToPath: false,
              ),
            ),
            errorBuilder: (context, error) {
              return Text('Parse error: $error');
            },
          ),
        ),
      );

      expect(
        find.textContaining('Parse error: Bad state: Missing required'),
        findsOneWidget,
      );
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

    testWidgets('document entrypoint accepts TagflowViewOptions.defaults', (
      tester,
    ) async {
      final document = _documentWithParagraph('Default view options');

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            viewOptions: TagflowViewOptions.defaults,
          ),
        ),
      );

      expect(find.text('Default view options'), findsOneWidget);
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

    testWidgets(
      'document entrypoint routes registry render errors to view options',
      (tester) async {
        final document = _documentWithParagraph('Built-in runtime');
        final registry = TagflowComponentRegistry(
          overrides: {
            TagflowNodeKind.paragraph: (context, node) {
              throw StateError('registry failed');
            },
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Tagflow.document(
              document,
              registry: registry,
              errorBuilder: (context, error) {
                return const Text('Widget-level error');
              },
              viewOptions: TagflowViewOptions(
                errorBuilder: (context, error) {
                  return Text('View options error: $error');
                },
              ),
            ),
          ),
        );

        expect(
          find.textContaining('View options error: Bad state: registry failed'),
          findsOneWidget,
        );
        expect(find.text('Widget-level error'), findsNothing);
        expect(find.text('Built-in runtime'), findsNothing);
      },
    );

    testWidgets('html entrypoint uses registry overrides', (tester) async {
      const html = '<p>Built-in HTML runtime</p>';
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            return const Text('Registry HTML paragraph');
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.html(html: html, registry: registry),
        ),
      );

      expect(find.text('Registry HTML paragraph'), findsOneWidget);
      expect(find.text('Built-in HTML runtime'), findsNothing);
    });

    testWidgets(
      'html entrypoint routes registry render errors to widget error builder',
      (tester) async {
        const html = '<p>Built-in HTML runtime</p>';
        final registry = TagflowComponentRegistry(
          overrides: {
            TagflowNodeKind.paragraph: (context, node) {
              throw StateError('html registry failed');
            },
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Tagflow.html(
              html: html,
              registry: registry,
              errorBuilder: (context, error) {
                return Text('Widget error: $error');
              },
            ),
          ),
        );

        expect(
          find.textContaining('Widget error: Bad state: html registry failed'),
          findsOneWidget,
        );
        expect(find.text('Built-in HTML runtime'), findsNothing);
      },
    );

    testWidgets('html registry does not replace legacy converters', (
      tester,
    ) async {
      const html = '<p>Built-in paragraph</p>';
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            return const Text('Registry paragraph');
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.html(
            html: html,
            registry: registry,
            converters: const [_LegacyParagraphConverter()],
          ),
        ),
      );

      expect(find.text('Legacy bridge'), findsOneWidget);
      expect(find.text('Registry paragraph'), findsNothing);
      expect(find.text('Built-in paragraph'), findsNothing);
    });

    testWidgets(
      'html registry changes rebuild semantic rendering without reparsing',
      (tester) async {
        const html = '<p>Built-in HTML runtime</p>';
        TagflowDocumentNode? firstParagraphNode;
        TagflowDocumentNode? secondParagraphNode;

        final firstRegistry = TagflowComponentRegistry(
          overrides: {
            TagflowNodeKind.paragraph: (context, node) {
              firstParagraphNode = node;
              return const Text('First registry paragraph');
            },
          },
        );
        final secondRegistry = TagflowComponentRegistry(
          overrides: {
            TagflowNodeKind.paragraph: (context, node) {
              secondParagraphNode = node;
              return Text(
                identical(node, firstParagraphNode)
                    ? 'Second registry reused node'
                    : 'Second registry reparsed node',
              );
            },
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Tagflow.html(html: html, registry: firstRegistry),
          ),
        );

        expect(find.text('First registry paragraph'), findsOneWidget);
        expect(firstParagraphNode, isNotNull);

        await tester.pumpWidget(
          MaterialApp(
            home: Tagflow.html(html: html, registry: secondRegistry),
          ),
        );

        expect(find.text('Second registry reused node'), findsOneWidget);
        expect(find.text('Second registry reparsed node'), findsNothing);
        expect(secondParagraphNode, same(firstParagraphNode));
      },
    );

    testWidgets('selectable wrapping applies around semantic content', (
      tester,
    ) async {
      final document = _documentWithParagraph('Selectable runtime');

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            viewOptions: TagflowViewOptions.defaults.copyWith(
              selectable: const TagflowSelectableOptions(enabled: true),
            ),
          ),
        ),
      );

      expect(find.byType(SelectionArea), findsOneWidget);
      expect(find.text('Selectable runtime'), findsOneWidget);
    });

    testWidgets('html render boundary stays on the html entrypoint', (
      tester,
    ) async {
      const html = '''
<p>Visible</p>
<!--end-of-mobile-->
<p>Hidden</p>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Tagflow.html(
            html: html,
            viewOptions: TagflowViewOptions.defaults,
            renderBoundary: TagflowRenderBoundary.comment(end: 'end-of-mobile'),
          ),
        ),
      );

      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
    });

    testWidgets('legacy TagflowOptions render boundary still works', (
      tester,
    ) async {
      const html = '''
<p>Visible</p>
<!--end-of-mobile-->
<p>Hidden</p>
''';

      await tester.pumpWidget(
        const MaterialApp(
          home: Tagflow(
            html: html,
            options: TagflowOptions(
              renderBoundary: TagflowRenderBoundary.comment(
                end: 'end-of-mobile',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Visible'), findsOneWidget);
      expect(find.text('Hidden'), findsNothing);
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

    test('default adapter keeps deterministic path-based node ids', () {
      const html = '<p>Hello <strong>runtime</strong></p>';
      final document = const TagflowHtmlAdapter().parse(html);
      final paragraph = document.children.single;

      expect(paragraph.id, TagflowNodeIds.fromPath([0]));
      expect(paragraph.children.first.id, TagflowNodeIds.fromPath([0, 0]));
      expect(
        _singleNodeWithHtmlTag(document, 'strong').id,
        TagflowNodeIds.fromPath([0, 1]),
      );
    });

    test('attribute node id strategy keeps authored element ids stable', () {
      const adapter = TagflowHtmlAdapter(
        nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
      );
      const beforeHtml = '''
<p data-tagflow-id="intro">Intro</p>
<p data-tagflow-id="body">Body</p>
''';
      const afterHtml = '''
<p data-tagflow-id="lead">Lead</p>
<p data-tagflow-id="intro">Intro</p>
<p data-tagflow-id="body">Body</p>
''';

      final before = adapter.parse(beforeHtml);
      final after = adapter.parse(afterHtml);

      expect(before.children[0].id, 'intro');
      expect(before.children[1].id, 'body');
      expect(after.children[1].id, 'intro');
      expect(after.children[2].id, 'body');
    });

    test('attribute strategy falls back to path ids for unannotated nodes', () {
      const adapter = TagflowHtmlAdapter(
        nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
      );
      const html =
          '<p data-tagflow-id="intro">Hello <strong>runtime</strong></p>';
      final document = adapter.parse(html);
      final paragraph = document.children.single;
      final text = paragraph.children.first;
      final strong = paragraph.children.last;

      expect(paragraph.id, 'intro');
      expect(text.id, TagflowNodeIds.fromPath([0, 0]));
      expect(strong.id, TagflowNodeIds.fromPath([0, 1]));
      expect(strong.children.single.id, TagflowNodeIds.fromPath([0, 1, 0]));
    });

    test('attribute strategy rejects duplicate authored ids', () {
      const adapter = TagflowHtmlAdapter(
        nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
      );

      expect(
        () => adapter.parse('''
<p data-tagflow-id="duplicate">One</p>
<p data-tagflow-id="duplicate">Two</p>
'''),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('duplicate'),
          ),
        ),
      );
    });

    test('attribute strategy rejects duplicate authored and fallback ids', () {
      const adapter = TagflowHtmlAdapter(
        nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
      );

      expect(
        () => adapter.parse('''
<p data-tagflow-id="0.1">Intro</p>
<p>Body</p>
'''),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('0.1'),
          ),
        ),
      );
    });

    test('attribute strategy without fallback fails on missing ids', () {
      const adapter = TagflowHtmlAdapter(
        nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(
          fallbackToPath: false,
        ),
      );

      expect(
        () => adapter.parse('<div data-tagflow-id="root"><hr></div>'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('data-tagflow-id'),
              contains('Missing required HTML node id attribute'),
            ),
          ),
        ),
      );
    });

    test('maps inline HTML semantics into first-class presentation', () {
      const html =
          '<p><strong>Strong</strong><b>Bold</b><em>Em</em><i>Italic</i>'
          '<u>Under</u><del>Gone</del><mark>Marked</mark><small>Small</small>'
          '<sub>Sub</sub><sup>Sup</sup></p>';
      final document = const TagflowHtmlAdapter().parse(html);

      final expected = {
        'strong': TagflowInlineSemantic.strong,
        'b': TagflowInlineSemantic.strong,
        'em': TagflowInlineSemantic.emphasis,
        'i': TagflowInlineSemantic.emphasis,
        'u': TagflowInlineSemantic.underline,
        'del': TagflowInlineSemantic.deleted,
        'mark': TagflowInlineSemantic.highlight,
        'small': TagflowInlineSemantic.small,
        'sub': TagflowInlineSemantic.subscript,
        'sup': TagflowInlineSemantic.superscript,
      };

      for (final entry in expected.entries) {
        final node = _singleNodeWithHtmlTag(document, entry.key);

        expect(node.kind, isNot(TagflowNodeKind.unsupported));
        expect(node.presentation.inlineSemantics, contains(entry.value));
      }
    });

    test('maps details and summary into supported runtime containers', () {
      const html = '''
<details open>
  <summary>Offer details</summary>
  <p>Issue size</p>
</details>
''';
      final document = const TagflowHtmlAdapter().parse(html);
      final details = _singleNodeWithHtmlTag(document, 'details');
      final summary = _singleNodeWithHtmlTag(document, 'summary');
      final attributes = details.metadata['htmlAttributes']! as Map;

      expect(details.kind, TagflowNodeKind.container);
      expect(details.presentation.variant, 'details');
      expect(details.kind, isNot(TagflowNodeKind.unsupported));
      expect(summary.kind, TagflowNodeKind.container);
      expect(summary.presentation.variant, 'summary');
      expect(summary.kind, isNot(TagflowNodeKind.unsupported));
      expect(attributes, contains('open'));
    });

    test('maps description lists into first-class runtime nodes', () {
      const html = '<dl><dt>Term</dt><dd>Definition</dd></dl>';

      final document = const TagflowHtmlAdapter().parse(html);
      final descriptionList = document.children.single;

      expect(descriptionList.kind, TagflowNodeKind.descriptionList);
      expect(descriptionList.children.map((node) => node.kind), [
        TagflowNodeKind.descriptionTerm,
        TagflowNodeKind.descriptionDetails,
      ]);
      expect(_flattenText(descriptionList.children), 'TermDefinition');
    });

    test('normalizes HTML table presentation hints for semantic renderers', () {
      const rowBackground = Color(0xFFE8F1FF);
      const cellBackground = Color(0xFFFFF4CC);
      const html = '''
<table border="2" cellpadding="6" cellspacing="4">
  <tr align="center" style="background-color: #e8f1ff;">
    <td>Row backed</td>
    <td align="right" style="background-color: #fff4cc; padding: 4px;">Cell backed</td>
  </tr>
</table>
''';
      final document = const TagflowHtmlAdapter().parse(html);
      final table = document.children.single;
      final row = table.children.single;
      final cell = row.children.last;

      expect(table.kind, TagflowNodeKind.table);
      expect(table.presentation.hints['tableBorderWidth'], 2.0);
      expect(table.presentation.hints['tableInsideBorderWidth'], 1.0);
      expect(table.presentation.hints['tableColumnSpacing'], 4.0);
      expect(table.presentation.hints['tableRowSpacing'], 4.0);
      expect(
        table.presentation.hints['tableCellPadding'],
        const EdgeInsets.all(6),
      );
      expect(row.presentation.hints['backgroundColor'], rowBackground);
      expect(row.presentation.hints['textAlign'], TextAlign.center);
      expect(cell.presentation.hints['backgroundColor'], cellBackground);
      expect(cell.presentation.hints['padding'], const EdgeInsets.all(4));
      expect(cell.presentation.hints['textAlign'], TextAlign.right);
    });

    test('ignores unsupported HTML table alignment hints', () {
      const html = '<table><tr><td align="middle">Cell</td></tr></table>';
      final document = const TagflowHtmlAdapter().parse(html);
      final cell = document.children.single.children.single.children.single;

      expect(cell.presentation.hints, isNot(contains('textAlign')));
    });

    test('bridges HTML table captions back to legacy table metadata', () {
      const html = '''
<table>
  <caption>Revenue summary</caption>
  <tr><td>Q1</td></tr>
</table>
''';
      final document = const TagflowHtmlAdapter().parse(html);

      final legacyNode = TagflowHtmlDocumentBridge.toLegacyNode(document);

      expect(legacyNode, isA<TagflowTableElement>());
      final table = legacyNode as TagflowTableElement;
      expect(table.rows, hasLength(1));
      expect(table.caption, isNotNull);
      expect(table.caption!.tag, 'caption');
      expect(_flattenLegacyText(table.caption!), 'Revenue summary');
    });

    test('bridges HTML disclosure tags back to legacy nodes', () {
      const html = '''
<details open>
  <summary>Offer details</summary>
  <p>Issue size</p>
</details>
''';
      final document = const TagflowHtmlAdapter().parse(html);

      final legacyNode = TagflowHtmlDocumentBridge.toLegacyNode(document);
      final details = _findLegacyTags(legacyNode, 'details').single;
      final summary = _findLegacyTags(legacyNode, 'summary').single;

      expect(details.attributes, containsPair('open', ''));
      expect(_flattenLegacyText(summary), 'Offer details');
    });

    test('bridges HTML description list tags back to legacy nodes', () {
      const html = '<dl><dt>Term</dt><dd>Definition</dd></dl>';
      final document = const TagflowHtmlAdapter().parse(html);

      final legacyNode = TagflowHtmlDocumentBridge.toLegacyNode(document);

      expect(_findLegacyTags(legacyNode, 'dl'), hasLength(1));
      expect(_findLegacyTags(legacyNode, 'dt'), hasLength(1));
      expect(_findLegacyTags(legacyNode, 'dd'), hasLength(1));
      expect(_flattenLegacyText(legacyNode), 'TermDefinition');
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

final class _ThrowingLegacyParagraphConverter
    extends ElementConverter<TagflowNode> {
  const _ThrowingLegacyParagraphConverter();

  @override
  Set<String> get supportedTags => {'p'};

  @override
  Widget convert(
    TagflowNode element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    throw StateError('legacy failed');
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

TagflowDocumentNode _singleNodeWithHtmlTag(
  TagflowDocument document,
  String htmlTag,
) {
  final nodes = [
    for (final child in document.children)
      ..._findNodesWithHtmlTag(child, htmlTag),
  ];

  expect(nodes, hasLength(1), reason: 'Expected one <$htmlTag> node.');
  return nodes.single;
}

List<TagflowDocumentNode> _findNodesWithHtmlTag(
  TagflowDocumentNode node,
  String htmlTag,
) {
  return [
    if (node.metadata['htmlTag'] == htmlTag ||
        node.presentation.hints['htmlTag'] == htmlTag)
      node,
    for (final child in node.children) ..._findNodesWithHtmlTag(child, htmlTag),
  ];
}

Finder _textWidgetWithData(String text) {
  return find.byWidgetPredicate((widget) {
    return widget is Text && widget.data == text;
  });
}

Finder _textWidgetWithSpan(String text) {
  return find.byWidgetPredicate((widget) {
    return widget is Text && widget.textSpan?.toPlainText() == text;
  });
}

TextStyle? _richTextStyle(WidgetTester tester, String text) {
  final finder = find.byWidgetPredicate((widget) {
    if (widget is! RichText) return false;
    return widget.text.toPlainText() == text;
  });

  if (finder.evaluate().isEmpty) {
    return null;
  }

  return tester.widget<RichText>(finder.first).text.style;
}

List<TagflowNode> _findLegacyTags(TagflowNode node, String tag) {
  return [
    if (node.tag == tag) node,
    for (final child in node.children) ..._findLegacyTags(child, tag),
  ];
}

String _flattenLegacyText(TagflowNode node) {
  final buffer = StringBuffer(node.textContent ?? '');
  for (final child in node.children) {
    buffer.write(_flattenLegacyText(child));
  }
  return buffer.toString();
}
