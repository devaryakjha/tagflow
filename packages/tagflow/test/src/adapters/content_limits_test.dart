import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

const _placeholders = TagflowUnsupportedBehavior.preservePlaceholder;

Iterable<TagflowDocumentNode> _walk(Iterable<TagflowDocumentNode> nodes) sync* {
  for (final node in nodes) {
    yield node;
    yield* _walk(node.children);
  }
}

int _depth(Iterable<TagflowDocumentNode> nodes) {
  var max = 0;
  for (final node in nodes) {
    final depth = 1 + _depth(node.children);
    if (depth > max) max = depth;
  }
  return max;
}

List<String?> _limitReasons(TagflowDocument document) {
  return [
    for (final node in _walk(document.children))
      if (node.kind == TagflowNodeKind.unsupported)
        node.metadata['policyDecisionReason'] as String?,
  ];
}

String _nestedDivs(int depth) => '${'<div>' * depth}x${'</div>' * depth}';

TagflowNativeBlock _nestedBlocks(int depth) {
  var block = TagflowNativeBlock.text(id: 'leaf', text: 'x');
  for (var i = depth - 1; i > 0; i--) {
    block = TagflowNativeBlock.container(id: 'c$i', children: [block]);
  }
  return block;
}

void main() {
  group('content policy limits', () {
    test('should default to maxDepth 128 and maxNodes 50000', () {
      const policy = TagflowContentPolicy.defaults;

      expect(policy.maxDepth, 128);
      expect(policy.maxNodes, 50000);
      expect(
        const TagflowContentPolicy(maxDepth: 4),
        isNot(TagflowContentPolicy.defaults),
      );
    });

    group('HTML', () {
      test('should cut nesting deeper than maxDepth without throwing', () {
        final document = const TagflowHtmlAdapter(
          policy: TagflowContentPolicy(maxDepth: 5),
        ).parse(_nestedDivs(20));

        expect(_depth(document.children), lessThanOrEqualTo(5));
        expect(_limitReasons(document), isEmpty);
      });

      test('should mark the cut with a placeholder under '
          'preservePlaceholder', () {
        final document = const TagflowHtmlAdapter(
          policy: TagflowContentPolicy(
            maxDepth: 5,
            unsupportedBehavior: _placeholders,
          ),
        ).parse(_nestedDivs(20));

        expect(_limitReasons(document), ['maxDepth']);
      });

      test('should cut content after maxNodes', () {
        final html = [for (var i = 0; i < 50; i++) '<p>p$i</p>'].join();
        final document = const TagflowHtmlAdapter(
          policy: TagflowContentPolicy(
            maxNodes: 20,
            unsupportedBehavior: _placeholders,
          ),
        ).parse(html);

        final paragraphs = document.children.where(
          (node) => node.kind == TagflowNodeKind.paragraph,
        );
        expect(paragraphs.length, lessThan(20));
        expect(_limitReasons(document), ['maxNodes']);
        expect(document.children.last.kind, TagflowNodeKind.unsupported);
      });

      test('should adapt 10000 nested elements quickly by default', () {
        final stopwatch = Stopwatch()..start();
        final document = const TagflowHtmlAdapter().parse(_nestedDivs(10000));
        stopwatch.stop();

        expect(_depth(document.children), lessThanOrEqualTo(128));
        // Was about 11 s before the limits; the HTML tokenizer alone takes
        // about 2 s here, so this only guards against the old blow-up.
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 6)));
      });

      test('should clamp colspan and rowspan as the HTML spec does', () {
        final stopwatch = Stopwatch()..start();
        final document = const TagflowHtmlAdapter().parse(
          '<table>'
          '<tr><td colspan="100000" rowspan="100000">x</td></tr> '
          '<tr><td>y</td></tr>'
          '</table>',
        );
        stopwatch.stop();

        final cell = document.children.single.children.first.children.single;
        expect(cell.colSpan, 1000);
        expect(cell.rowSpan, 65534);
        expect(_walk(document.children).length, lessThan(20));
        expect(stopwatch.elapsed, lessThan(const Duration(seconds: 1)));
      });

      test('should treat zero and negative spans as 1', () {
        final document = const TagflowHtmlAdapter().parse(
          '<table><tr><td colspan="0" rowspan="-3">x</td></tr></table>',
        );

        final cell = document.children.single.children.single.children.single;
        expect(cell.colSpan, 1);
        expect(cell.rowSpan, 1);
      });
    });

    group('Markdown', () {
      test('should cut nesting deeper than maxDepth', () {
        final document = const TagflowMarkdownAdapter(
          policy: TagflowContentPolicy(
            maxDepth: 4,
            unsupportedBehavior: _placeholders,
          ),
        ).parse('${'> ' * 20}deep');

        // The placeholder sits where the cut content was, one level deeper.
        expect(_depth(document.children), 5);
        expect(_limitReasons(document), ['maxDepth']);
      });

      test('should cut content after maxNodes', () {
        final markdown = [for (var i = 0; i < 50; i++) 'p$i'].join('\n\n');
        final document = const TagflowMarkdownAdapter(
          policy: TagflowContentPolicy(maxNodes: 20),
        ).parse(markdown);

        expect(_walk(document.children).length, lessThanOrEqualTo(20));
        expect(_limitReasons(document), isEmpty);
      });

      test('should apply limits in the Markdown stream', () {
        final stream = TagflowMarkdownStream(
          adapter: const TagflowMarkdownAdapter(
            policy: TagflowContentPolicy(maxDepth: 4),
          ),
        )..add('${'> ' * 20}deep\n\nnext');

        expect(_depth(stream.document.children), lessThanOrEqualTo(4));
      });
    });

    group('native blocks', () {
      test('should cut nesting deeper than maxDepth', () {
        final document =
            const TagflowNativeBlockAdapter(
              policy: TagflowContentPolicy(
                maxDepth: 5,
                unsupportedBehavior: _placeholders,
              ),
            ).adapt(
              TagflowNativeBlockDocument(
                id: 'd',
                schemaVersion: 1,
                blocks: [_nestedBlocks(20)],
              ),
            );

        // The placeholder sits where the cut content was, one level deeper.
        expect(_depth(document.children), 6);
        expect(_limitReasons(document), ['maxDepth']);
      });

      test('should cut content after maxNodes', () {
        final document =
            const TagflowNativeBlockAdapter(
              policy: TagflowContentPolicy(maxNodes: 10),
            ).adapt(
              TagflowNativeBlockDocument(
                id: 'd',
                schemaVersion: 1,
                blocks: [
                  for (var i = 0; i < 30; i++)
                    TagflowNativeBlock.text(id: 't$i', text: '$i'),
                ],
              ),
            );

        expect(document.children, hasLength(10));
      });

      test('should clamp native table spans', () {
        final document = const TagflowNativeBlockAdapter().adapt(
          TagflowNativeBlockDocument(
            id: 'd',
            schemaVersion: 1,
            blocks: [
              TagflowNativeBlock.table(
                id: 't',
                children: [
                  TagflowNativeBlock.tableRow(
                    id: 'r',
                    children: [
                      TagflowNativeBlock.tableCell(
                        id: 'c',
                        colSpan: 100000,
                        rowSpan: 100000,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );

        final cell = document.children.single.children.single.children.single;
        expect(cell.colSpan, 1000);
        expect(cell.rowSpan, 65534);
      });
    });
  });
}
