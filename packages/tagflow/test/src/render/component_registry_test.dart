import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

void main() {
  group('TagflowComponentRegistry', () {
    test(
      'can render every semantic node kind through a component or fallback',
      () {
        final registry = TagflowComponentRegistry.builtIn;

        for (final kind in TagflowNodeKind.values) {
          expect(registry.canRender(kind), isTrue, reason: '$kind');
        }

        expect(registry.hasComponent(TagflowNodeKind.paragraph), isTrue);
        expect(registry.hasComponent(TagflowNodeKind.text), isTrue);
        expect(registry.hasComponent(TagflowNodeKind.unsupported), isTrue);
      },
    );

    testWidgets('distinguishes full registries from extension fragments', (
      tester,
    ) async {
      final fullRegistry = TagflowComponentRegistry();
      final fragment = TagflowComponentRegistry.components(
        components: const {},
      );

      expect(fullRegistry.hasComponent(TagflowNodeKind.paragraph), isTrue);
      expect(fullRegistry.canRender(TagflowNodeKind.paragraph), isTrue);
      expect(fragment.hasComponent(TagflowNodeKind.paragraph), isFalse);
      expect(fragment.canRender(TagflowNodeKind.paragraph), isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return fragment.render(
                context,
                TagflowDocumentNode.paragraph(id: 'paragraph'),
              );
            },
          ),
        ),
      );

      expect(
        tester.takeException(),
        isA<UnsupportedError>().having(
          (error) => error.message,
          'message',
          contains('No Tagflow component registered'),
        ),
      );
    });

    testWidgets('uses app override before built-in component', (tester) async {
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            return const Text('Paragraph override');
          },
        },
      );
      final node = TagflowDocumentNode.paragraph(
        id: 'p1',
        children: [TagflowDocumentNode.text(id: 't1', text: 'Built-in text')],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) => registry.render(context, node)),
        ),
      );

      expect(find.text('Paragraph override'), findsOneWidget);
      expect(find.text('Built-in text'), findsNothing);
    });

    testWidgets('preserves component state by semantic node id', (
      tester,
    ) async {
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            return _StatefulParagraphLabel(nodeId: node.id);
          },
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            _paragraphDocument(['first', 'second']),
            registry: registry,
          ),
        ),
      );

      expect(find.text('first/state:first'), findsOneWidget);
      expect(find.text('second/state:second'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            _paragraphDocument(['second', 'first']),
            registry: registry,
          ),
        ),
      );

      expect(find.text('first/state:first'), findsOneWidget);
      expect(find.text('second/state:second'), findsOneWidget);
      expect(find.text('first/state:second'), findsNothing);
      expect(find.text('second/state:first'), findsNothing);
    });

    testWidgets('renders unsupported nodes with predictable fallback', (
      tester,
    ) async {
      final node = TagflowDocumentNode.unsupported(
        id: 'unsupported1',
        unsupportedReason: 'custom element',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return TagflowComponentRegistry.builtIn.render(context, node);
            },
          ),
        ),
      );

      expect(find.byType(DecoratedBox), findsOneWidget);
      expect(find.text('Unsupported content'), findsOneWidget);
      expect(find.textContaining('custom element'), findsNothing);
    });

    testWidgets('renders preserved native policy rejections as placeholders', (
      tester,
    ) async {
      const adapter = TagflowNativeBlockAdapter(
        policy: TagflowContentPolicy(
          allowRemoteImages: false,
          unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
        ),
      );
      final nativeDocument = TagflowNativeBlockDocument(
        id: 'native-doc',
        schemaVersion: 1,
        blocks: [
          TagflowNativeBlock.image(
            id: 'blocked-image',
            url: 'https://example.com/image.png',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(adapter.adapt(nativeDocument))),
      );

      expect(find.text('Unsupported content'), findsOneWidget);
      expect(find.textContaining('rejected by policy'), findsNothing);
    });

    testWidgets('renders first-class inline presentation semantics', (
      tester,
    ) async {
      final document = TagflowDocument(
        id: 'doc-inline-semantics',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'p',
            children: [
              TagflowDocumentNode.text(id: 't0', text: 'Hello '),
              TagflowDocumentNode.container(
                id: 'strong',
                presentation: TagflowPresentation(
                  inlineSemantics: const {TagflowInlineSemantic.strong},
                ),
                children: [TagflowDocumentNode.text(id: 't1', text: 'bold')],
              ),
              TagflowDocumentNode.text(id: 't2', text: ' and '),
              TagflowDocumentNode.container(
                id: 'emphasis',
                presentation: TagflowPresentation(
                  inlineSemantics: const {TagflowInlineSemantic.emphasis},
                ),
                children: [TagflowDocumentNode.text(id: 't3', text: 'italic')],
              ),
              TagflowDocumentNode.text(id: 't4', text: ' and '),
              TagflowDocumentNode.container(
                id: 'mark',
                presentation: TagflowPresentation(
                  inlineSemantics: const {TagflowInlineSemantic.highlight},
                ),
                children: [TagflowDocumentNode.text(id: 't5', text: 'marked')],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(find.text('Hello '), findsOneWidget);
      expect(find.text('bold'), findsOneWidget);
      expect(find.text(' and '), findsNWidgets(2));
      expect(find.text('italic'), findsOneWidget);
      expect(find.text('marked'), findsOneWidget);
      expect(_richTextStyle(tester, 'bold')?.fontWeight, FontWeight.w700);
      expect(_richTextStyle(tester, 'italic')?.fontStyle, FontStyle.italic);
      expect(
        find.ancestor(
          of: find.text('marked'),
          matching: find.byType(DecoratedBox),
        ),
        findsWidgets,
      );
    });

    testWidgets('keeps html hint fallback for legacy unsupported nodes', (
      tester,
    ) async {
      final document = TagflowDocument(
        id: 'doc-legacy-inline-hints',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'p',
            children: [
              TagflowDocumentNode.unsupported(
                id: 'legacy-strong',
                presentation: TagflowPresentation(
                  hints: const {'htmlTag': 'strong'},
                ),
                children: [TagflowDocumentNode.text(id: 't1', text: 'bold')],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(find.text('bold'), findsOneWidget);
      expect(_richTextStyle(tester, 'bold')?.fontWeight, FontWeight.w700);
    });

    testWidgets('applies link callbacks from semantic runtime nodes', (
      tester,
    ) async {
      String? tappedUrl;
      LinkedHashMap<String, String>? tappedAttributes;
      TagflowDocumentNode? tappedNode;
      final document = const TagflowHtmlAdapter().parse(
        '<p><a href="https://example.com/story" title="Story">Open</a></p>',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            options: TagflowOptions(
              linkTapCallback: (url, attributes) {
                tappedUrl = url;
                tappedAttributes = attributes;
              },
              nodeTapCallback: (details) {
                tappedNode = details.node;
              },
              tapTargetKinds: const {TagflowNodeKind.link},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();

      expect(tappedUrl, 'https://example.com/story');
      expect(tappedAttributes?['href'], 'https://example.com/story');
      expect(tappedAttributes?['title'], 'Story');
      expect(tappedNode, isNull);
    });

    testWidgets('does not make non-link nodes tappable by default', (
      tester,
    ) async {
      TagflowDocumentNode? tappedNode;
      final document = TagflowDocument(
        id: 'doc-default-node-tap',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'paragraph',
            children: [TagflowDocumentNode.text(id: 'text', text: 'Read')],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            viewOptions: TagflowViewOptions(
              nodeTapCallback: (details) {
                tappedNode = details.node;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Read'));
      await tester.pump();

      expect(tappedNode, isNull);
    });

    testWidgets('applies node tap callbacks to opted-in document nodes', (
      tester,
    ) async {
      BuildContext? tappedContext;
      TagflowDocumentNode? tappedNode;
      final document = TagflowDocument(
        id: 'doc-node-tap',
        children: [
          TagflowDocumentNode.container(
            id: 'card',
            children: [
              TagflowDocumentNode.paragraph(
                id: 'card.body',
                children: [
                  TagflowDocumentNode.text(id: 'card.text', text: 'Open card'),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            viewOptions: TagflowViewOptions(
              nodeTapCallback: (details) {
                tappedContext = details.context;
                tappedNode = details.node;
              },
              tapTargetKinds: const {TagflowNodeKind.container},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open card'));
      await tester.pump();

      expect(tappedContext, isNotNull);
      expect(tappedNode?.id, 'card');
      expect(tappedNode?.kind, TagflowNodeKind.container);
    });

    testWidgets('applies node tap callbacks to opted-in HTML nodes', (
      tester,
    ) async {
      TagflowDocumentNode? tappedNode;

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.html(
            html:
                '<section data-tagflow-id="summary" data-action="open"> '
                '<p>Open summary</p> '
                '</section>',
            adapter: const TagflowHtmlAdapter(
              nodeIdStrategy: TagflowHtmlNodeIdStrategy.attribute(),
            ),
            viewOptions: TagflowViewOptions(
              nodeTapCallback: (details) {
                tappedNode = details.node;
              },
              tapTargetKinds: const {TagflowNodeKind.container},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open summary'));
      await tester.pump();

      expect(tappedNode?.id, 'summary');
      expect(tappedNode?.kind, TagflowNodeKind.container);
      expect(tappedNode?.metadata['htmlTag'], 'section');
      expect(
        tappedNode?.metadata['htmlAttributes'],
        containsPair('data-action', 'open'),
      );
    });

    testWidgets('applies node tap callbacks to list items rendered by lists', (
      tester,
    ) async {
      TagflowDocumentNode? tappedNode;
      final document = TagflowDocument(
        id: 'doc-list-item-tap',
        children: [
          TagflowDocumentNode.list(
            id: 'actions',
            ordered: false,
            children: [
              TagflowDocumentNode.listItem(
                id: 'actions.review',
                children: [
                  TagflowDocumentNode.paragraph(
                    id: 'actions.review.body',
                    children: [
                      TagflowDocumentNode.text(
                        id: 'actions.review.body.text',
                        text: 'Review checklist',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            viewOptions: TagflowViewOptions(
              nodeTapCallback: (details) {
                tappedNode = details.node;
              },
              tapTargetKinds: const {TagflowNodeKind.listItem},
            ),
          ),
        ),
      );

      await tester.tap(find.text('Review checklist'));
      await tester.pump();

      expect(tappedNode?.id, 'actions.review');
      expect(tappedNode?.kind, TagflowNodeKind.listItem);
    });

    testWidgets('renders ordered and unordered list markers semantically', (
      tester,
    ) async {
      final document = const TagflowHtmlAdapter().parse(
        '<ol start="3"><li>Third</li><li>Fourth</li></ol> '
        '<ul><li>Bullet</li></ul>',
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(find.text('3.'), findsOneWidget);
      expect(find.text('4.'), findsOneWidget);
      expect(find.text('•'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
      expect(find.text('Fourth'), findsOneWidget);
      expect(find.text('Bullet'), findsOneWidget);
    });

    testWidgets('renders description lists semantically', (tester) async {
      final document = const TagflowHtmlAdapter().parse(
        '<dl><dt>Term</dt><dd>Definition</dd></dl>',
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(document.children.single.kind, TagflowNodeKind.descriptionList);
      expect(find.text('Term'), findsOneWidget);
      expect(find.text('Definition'), findsOneWidget);
      expect(_richTextStyle(tester, 'Term')?.fontWeight, FontWeight.w700);
      expect(
        tester.getTopLeft(find.text('Definition')).dx,
        greaterThan(tester.getTopLeft(find.text('Term')).dx),
      );
      expect(find.text('Unsupported content'), findsNothing);
    });

    testWidgets('renders html details through the document registry', (
      tester,
    ) async {
      final document = const TagflowHtmlAdapter().parse(
        '<details><summary>Disclosure</summary><p>Hidden body</p></details>',
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(find.text('Disclosure'), findsOneWidget);
      expect(find.text('Hidden body'), findsNothing);

      await tester.tap(find.text('Disclosure'));
      await tester.pump();

      expect(find.text('Hidden body'), findsOneWidget);

      await tester.tap(find.text('Disclosure'));
      await tester.pump();

      expect(find.text('Hidden body'), findsNothing);
    });

    testWidgets('renders open details and fallback summary through registry', (
      tester,
    ) async {
      final openDocument = const TagflowHtmlAdapter().parse(
        '<details open><summary>Expanded</summary><p>Visible body</p></details>',
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(openDocument)),
      );

      expect(find.text('Expanded'), findsOneWidget);
      expect(find.text('Visible body'), findsOneWidget);

      final fallbackDocument = const TagflowHtmlAdapter().parse(
        '<details><p>Fallback body</p></details>',
      );

      await tester.pumpWidget(
        MaterialApp(home: Tagflow.document(fallbackDocument)),
      );

      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Fallback body'), findsNothing);

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(find.text('Fallback body'), findsOneWidget);
    });

    testWidgets('keeps mixed summary content inline in disclosure titles', (
      tester,
    ) async {
      final document = const TagflowHtmlAdapter().parse(
        '<details open><summary>Read <strong>more</strong></summary>'
        ' <p>Body</p></details>',
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(find.text('Read '), findsOneWidget);
      expect(find.text('more'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Read ')).dy,
        tester.getTopLeft(find.text('more')).dy,
      );
    });

    testWidgets('renders native blockquote and code styling', (tester) async {
      final document = TagflowDocument(
        id: 'doc-quote-code',
        children: [
          TagflowDocumentNode.blockquote(
            id: 'quote',
            children: [
              TagflowDocumentNode.paragraph(
                id: 'quote-p',
                children: [
                  TagflowDocumentNode.text(id: 'quote-t', text: 'Quoted copy'),
                ],
              ),
            ],
          ),
          TagflowDocumentNode.codeBlock(id: 'code', text: 'final value = 1;'),
        ],
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      expect(
        find.ancestor(
          of: find.text('Quoted copy'),
          matching: find.byType(DecoratedBox),
        ),
        findsWidgets,
      );
      expect(
        find.ancestor(
          of: find.text('final value = 1;'),
          matching: find.byType(DecoratedBox),
        ),
        findsWidgets,
      );
      expect(
        tester.widget<Text>(find.text('final value = 1;')).style?.fontFamily,
        'monospace',
      );
    });

    testWidgets('applies semantic image view options from context', (
      tester,
    ) async {
      final document = TagflowDocument(
        id: 'doc-image',
        children: [
          TagflowDocumentNode.image(
            id: 'image',
            url: Uri.parse('https://example.com/image.png'),
            alt: 'Hero image',
            width: 640,
            height: 480,
          ),
        ],
      );

      Widget loadingBuilder(
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        return const Text('Loading image');
      }

      Widget errorBuilder(
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return const Text('Broken image');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Tagflow.document(
            document,
            options: TagflowOptions(
              imageLoadingBuilder: loadingBuilder,
              imageErrorBuilder: errorBuilder,
              maxImageWidth: 320,
              maxImageHeight: 240,
            ),
          ),
        ),
      );
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      tester.takeException();

      expect(image.width, 320);
      expect(image.height, 240);
      expect(image.loadingBuilder, same(loadingBuilder));
      expect(image.errorBuilder, same(errorBuilder));
    });

    testWidgets('renders simple semantic tables', (tester) async {
      final document = TagflowDocument(
        id: 'doc-table',
        children: [
          TagflowDocumentNode.table(
            id: 'table',
            children: [
              TagflowDocumentNode.tableRow(
                id: 'row-header',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'cell-header',
                    header: true,
                    children: [
                      TagflowDocumentNode.text(id: 'header-text', text: 'Name'),
                    ],
                  ),
                ],
              ),
              TagflowDocumentNode.tableRow(
                id: 'row-body',
                children: [
                  TagflowDocumentNode.tableCell(
                    id: 'cell-body',
                    children: [
                      TagflowDocumentNode.text(
                        id: 'body-text',
                        text: 'Tagflow',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp(home: Tagflow.document(document)));

      final table = tester.widget<Table>(find.byType(Table));

      expect(table.children, hasLength(2));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Tagflow'), findsOneWidget);
      expect(_richTextStyle(tester, 'Name')?.fontWeight, FontWeight.w700);
    });
  });
}

TagflowDocument _paragraphDocument(List<String> ids) {
  return TagflowDocument(
    id: 'document',
    children: [
      for (final id in ids)
        TagflowDocumentNode.paragraph(
          id: id,
          children: [TagflowDocumentNode.text(id: '$id.text', text: id)],
        ),
    ],
  );
}

final class _StatefulParagraphLabel extends StatefulWidget {
  const _StatefulParagraphLabel({required this.nodeId});

  final String nodeId;

  @override
  State<_StatefulParagraphLabel> createState() =>
      _StatefulParagraphLabelState();
}

final class _StatefulParagraphLabelState
    extends State<_StatefulParagraphLabel> {
  late final String stateNodeId = widget.nodeId;

  @override
  Widget build(BuildContext context) {
    return Text('${widget.nodeId}/state:$stateNodeId');
  }
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
