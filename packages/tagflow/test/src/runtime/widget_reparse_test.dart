import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

final class _Probe extends StatefulWidget {
  const _Probe({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_Probe> createState() => _ProbeState();
}

final class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox(height: 10);
}

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('Tagflow widget state', () {
    var inits = 0;
    final registry = TagflowComponentRegistry(
      overrides: {
        TagflowNodeKind.codeBlock: (context, node) =>
            _Probe(onInit: () => inits++),
      },
    );

    setUp(() => inits = 0);

    testWidgets('should keep unchanged node state when the html string '
        'changes', (tester) async {
      for (final tail in ['hello', 'hello world', 'hello world again']) {
        await tester.pumpWidget(
          _app(
            Tagflow.html(
              html: '<pre><code>x = 1</code></pre><p>$tail</p>',
              registry: registry,
            ),
          ),
        );
        expect(find.text(tail), findsOneWidget);
      }

      expect(inits, 1);
    });

    testWidgets('should keep unchanged node state when the markdown string '
        'changes', (tester) async {
      for (final tail in ['hello', 'hello world', 'hello world again']) {
        await tester.pumpWidget(
          _app(
            Tagflow.markdown(
              markdown: '```\nx = 1\n```\n\n$tail',
              registry: registry,
            ),
          ),
        );
        expect(find.text(tail), findsOneWidget);
      }

      expect(inits, 1);
    });

    testWidgets('should remount when the caller changes the document id', (
      tester,
    ) async {
      for (final id in ['a', 'b']) {
        await tester.pumpWidget(
          _app(
            Tagflow.html(
              html: '<pre><code>x = 1</code></pre>',
              documentId: id,
              registry: registry,
            ),
          ),
        );
      }

      expect(inits, 2);
    });
  });

  group('Tagflow re-parsing', () {
    final seen = <TagflowDocumentNode>[];
    final registry = TagflowComponentRegistry(
      overrides: {
        TagflowNodeKind.heading: (context, node) {
          seen.add(node);
          return const SizedBox();
        },
      },
    );

    setUp(seen.clear);

    testWidgets('should not re-parse when the parent rebuilds with an inline '
        'callback', (tester) async {
      for (var i = 0; i < 2; i++) {
        await tester.pumpWidget(
          _app(
            Tagflow.html(
              html: '<h1>T</h1>',
              registry: registry,
              viewOptions: TagflowViewOptions(linkTapCallback: (url, a) {}),
            ),
          ),
        );
      }

      expect(seen, hasLength(2));
      expect(identical(seen[0], seen[1]), isTrue);
    });

    testWidgets('should not re-parse with an equal non-const adapter', (
      tester,
    ) async {
      for (var i = 0; i < 2; i++) {
        await tester.pumpWidget(
          _app(
            Tagflow.html(
              html: '<h1>T</h1>',
              registry: registry,
              // A new adapter instance on every build.
              // ignore: prefer_const_constructors, the point of the test
              adapter: TagflowHtmlAdapter(
                // ignore: prefer_const_constructors, the point of the test
                policy: TagflowContentPolicy(allowRelativeUrls: false),
              ),
            ),
          ),
        );
      }

      expect(seen, hasLength(2));
      expect(identical(seen[0], seen[1]), isTrue);
    });

    testWidgets('should re-parse when the content policy changes', (
      tester,
    ) async {
      for (final allowRelativeUrls in [false, true]) {
        await tester.pumpWidget(
          _app(
            Tagflow.html(
              html: '<h1>T</h1>',
              registry: registry,
              adapter: TagflowHtmlAdapter(
                policy: TagflowContentPolicy(
                  allowRelativeUrls: allowRelativeUrls,
                ),
              ),
            ),
          ),
        );
      }

      expect(seen, hasLength(2));
      expect(identical(seen[0], seen[1]), isFalse);
    });

    testWidgets('should use the latest view options without re-parsing', (
      tester,
    ) async {
      final taps = <String>[];
      for (final label in ['first', 'second']) {
        await tester.pumpWidget(
          _app(
            Tagflow.html(
              html: '<p><a href="https://example.com">link</a></p>',
              viewOptions: TagflowViewOptions(
                linkTapCallback: (url, attributes) => taps.add(label),
              ),
            ),
          ),
        );
      }

      await tester.tap(find.textContaining('link'));
      expect(taps, ['second']);
    });
  });
}
