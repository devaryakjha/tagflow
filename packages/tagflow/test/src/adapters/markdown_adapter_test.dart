import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  const adapter = TagflowMarkdownAdapter();

  group('TagflowMarkdownAdapter', () {
    test('tags the document and nodes with markdown source metadata', () {
      final document = adapter.parse(
        '# Hello',
        uri: Uri.parse('https://example.com/answer.md'),
      );

      expect(document.id, startsWith('markdown-'));
      expect(document.source?.kind, TagflowSourceKind.markdown);
      expect(document.source?.adapter, 'markdown');
      expect(document.source?.uri, Uri.parse('https://example.com/answer.md'));

      final heading = document.children.single;
      expect(heading.source?.kind, TagflowSourceKind.markdown);
      expect(heading.markdownTag, 'h1');
      expect(heading.isMarkdownRawHtml, isFalse);
    });

    test('uses explicit document id and metadata when given', () {
      final document = adapter.parse(
        'Hi',
        id: 'answer-1',
        metadata: TagflowMetadata(const {'turn': 3}),
      );

      expect(document.id, 'answer-1');
      expect(document.metadata['turn'], 3);
    });

    test('produces the same document id for the same markdown', () {
      expect(adapter.parse('a').id, adapter.parse('a').id);
      expect(adapter.parse('a').id, isNot(adapter.parse('b').id));
    });

    test('maps headings h1 through h6', () {
      final document = adapter.parse(
        '# 1\n## 2\n### 3\n#### 4\n##### 5\n###### 6',
      );

      expect(document.children.map((node) => node.kind), [
        for (var i = 0; i < 6; i++) TagflowNodeKind.heading,
      ]);
      expect(document.children.map((node) => node.level), [1, 2, 3, 4, 5, 6]);
      expect(document.children.first.children.single.text, '1');
    });

    test('maps paragraphs with soft and hard line breaks', () {
      final paragraph = adapter.parse('one\ntwo  \nthree').children.single;

      expect(paragraph.kind, TagflowNodeKind.paragraph);
      expect(paragraph.children.map((node) => node.text), [
        'one two',
        '\n',
        'three',
      ]);
      expect(paragraph.children[1].markdownTag, isNull);
    });

    test('maps emphasis, strong and strikethrough to inline semantics', () {
      final paragraph = adapter
          .parse('*em* **strong** ~~gone~~')
          .children
          .single;
      final inline = paragraph.children
          .where((node) => node.kind == TagflowNodeKind.container)
          .toList();

      expect(inline.map((node) => node.presentation.inlineSemantics), [
        {TagflowInlineSemantic.emphasis},
        {TagflowInlineSemantic.strong},
        {TagflowInlineSemantic.deleted},
      ]);
      expect(inline.map((node) => node.markdownTag), ['em', 'strong', 'del']);
      expect(inline.last.children.single.text, 'gone');
    });

    test('decodes entities and keeps literal characters as text', () {
      final paragraph = adapter
          .parse('Tom &amp; Jerry &copy; 1 < 2')
          .children
          .single;

      expect(paragraph.children.single.text, 'Tom & Jerry © 1 < 2');
    });

    test('maps inline code and fenced code blocks with language', () {
      final document = adapter.parse(
        'Use `flutter test`.\n\n```dart\nvoid main() {}\n```\n\n'
        '```\nplain\n```',
      );

      final inlineCode = document.children[0].children[1];
      expect(inlineCode.kind, TagflowNodeKind.inlineCode);
      expect(inlineCode.text, 'flutter test');

      final codeBlock = document.children[1];
      expect(codeBlock.kind, TagflowNodeKind.codeBlock);
      expect(codeBlock.text, 'void main() {}');
      expect(codeBlock.language, 'dart');

      expect(document.children[2].text, 'plain');
      expect(document.children[2].language, isNull);
    });

    test('maps indented code blocks', () {
      final codeBlock = adapter.parse('    indented\n    code').children.single;

      expect(codeBlock.kind, TagflowNodeKind.codeBlock);
      expect(codeBlock.text, 'indented\ncode');
    });

    test('maps unordered and ordered lists with start index', () {
      final document = adapter.parse('- a\n- b\n\n3. c\n4. d');

      final unordered = document.children[0];
      expect(unordered.kind, TagflowNodeKind.list);
      expect(unordered.ordered, isFalse);
      expect(unordered.children.map((node) => node.kind), [
        TagflowNodeKind.listItem,
        TagflowNodeKind.listItem,
      ]);

      final ordered = document.children[1];
      expect(ordered.ordered, isTrue);
      expect(ordered.startIndex, 3);
      expect(ordered.children.first.children.single.text, 'c');
    });

    test('maps nested lists', () {
      final list = adapter.parse('- a\n  - b').children.single;
      final nested = list.children.single.children.last;

      expect(nested.kind, TagflowNodeKind.list);
      expect(nested.children.single.children.single.text, 'b');
    });

    test('maps GFM task lists to task metadata without checkbox nodes', () {
      final list = adapter
          .parse('- [ ] todo\n- [x] done\n- plain')
          .children
          .single;

      expect(list.children.map((item) => item.isMarkdownTaskItem), [
        isTrue,
        isTrue,
        isFalse,
      ]);
      expect(list.children.map((item) => item.markdownTaskChecked), [
        false,
        true,
        null,
      ]);
      expect(list.children.first.children.single.text, 'todo');
      expect(
        list.children.expand((item) => item.children).map((node) => node.kind),
        everyElement(TagflowNodeKind.text),
      );
    });

    test('maps loose GFM task lists', () {
      final list = adapter.parse('- [x] done\n\n- [ ] todo').children.single;

      expect(list.children.map((item) => item.markdownTaskChecked), [
        true,
        false,
      ]);
      final paragraph = list.children.first.children.single;
      expect(paragraph.kind, TagflowNodeKind.paragraph);
      expect(paragraph.children.single.text, 'done');
    });

    test('maps blockquotes and horizontal rules', () {
      final document = adapter.parse('> quoted\n\n---');

      expect(document.children[0].kind, TagflowNodeKind.blockquote);
      expect(
        document.children[0].children.single.kind,
        TagflowNodeKind.paragraph,
      );
      expect(document.children[1].kind, TagflowNodeKind.horizontalRule);
    });

    test('maps links with titles and GFM autolinks', () {
      final paragraph = adapter
          .parse('[docs](https://docs.arya.run "Docs") www.example.com')
          .children
          .single;
      final links = paragraph.children
          .where((node) => node.kind == TagflowNodeKind.link)
          .toList();

      expect(links.first.url, Uri.parse('https://docs.arya.run'));
      expect(links.first.metadata['title'], 'Docs');
      expect(links.first.children.single.text, 'docs');
      expect(links.last.url, Uri.parse('http://www.example.com'));
    });

    test('maps images with alt text and title', () {
      final image = adapter
          .parse('![A cat](https://example.com/cat.png "Cat")')
          .children
          .single
          .children
          .single;

      expect(image.kind, TagflowNodeKind.image);
      expect(image.url, Uri.parse('https://example.com/cat.png'));
      expect(image.alt, 'A cat');
      expect(image.metadata['title'], 'Cat');
    });

    test('maps GFM tables to flat rows with header cells and alignment', () {
      final table = adapter
          .parse('| a | b | c |\n|:--|:-:|--:|\n| 1 | **2** | 3 |')
          .children
          .single;

      expect(table.kind, TagflowNodeKind.table);
      expect(table.metadata['tableRowCount'], 2);
      expect(table.metadata['tableColumnCount'], 3);
      expect(table.children.map((row) => row.kind), [
        TagflowNodeKind.tableRow,
        TagflowNodeKind.tableRow,
      ]);

      final header = table.children.first.children;
      expect(header.map((cell) => cell.header), [true, true, true]);
      expect(header.map((cell) => cell.presentation.hints['textAlign']), [
        TextAlign.left,
        TextAlign.center,
        TextAlign.right,
      ]);

      final body = table.children.last.children;
      expect(body.map((cell) => cell.header), [false, false, false]);
      expect(body[1].children.single.presentation.inlineSemantics, {
        TagflowInlineSemantic.strong,
      });
    });

    test('maps footnotes to superscript references and a footnote section', () {
      final document = adapter.parse('Claim[^1].\n\n[^1]: Source.');
      final reference = document.children.first.children[1];

      expect(reference.presentation.inlineSemantics, {
        TagflowInlineSemantic.superscript,
      });
      expect(reference.children.single.kind, TagflowNodeKind.link);
      expect(document.children.last.markdownTag, 'section');
    });

    test('assigns deterministic block-index ids', () {
      final document = adapter.parse('# Title\n\nText *em*\n\n- a\n- b');

      expect(document.children.map((node) => node.id), ['0.0', '0.1', '0.2']);
      expect(document.children[1].children.map((node) => node.id), [
        '0.1.0',
        '0.1.1',
      ]);
      expect(document.children[1].children[1].children.single.id, '0.1.1.0');
      expect(document.children[2].children.map((node) => node.id), [
        '0.2.0',
        '0.2.1',
      ]);
      expect(
        () => TagflowDocument.validated(
          id: document.id,
          children: document.children,
        ),
        returnsNormally,
      );
    });

    test('keeps ids of earlier blocks stable as markdown grows', () {
      const prefix = '# Title\n\nFirst paragraph.\n\n';
      final partial = adapter.parse('${prefix}Second');
      final complete = adapter.parse('${prefix}Second paragraph.\n\n- item');

      expect(partial.children.take(2), complete.children.take(2));
      expect(complete.children[2].id, partial.children[2].id);
      expect(complete.children[3].id, '0.3');
    });

    test('applies the content policy to links and images', () {
      final document = adapter.parse(
        '[bad](javascript:alert(1)) ![img](https://example.com/a.png)',
      );
      final paragraph = document.children.single;

      final link = paragraph.children.first;
      expect(link.kind, TagflowNodeKind.container);
      expect(link.metadata['policyDecisionReason'], 'disallowedScheme');
      expect(link.children.single.text, 'bad');

      final noRemoteImages = const TagflowMarkdownAdapter(
        policy: TagflowContentPolicy(
          allowRemoteImages: false,
          unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
        ),
      ).parse('![img](https://example.com/a.png)');
      final image = noRemoteImages.children.single.children.single;
      expect(image.kind, TagflowNodeKind.unsupported);
      expect(image.metadata['policyDecisionReason'], 'remoteImagesDisabled');
      expect(image.metadata['blockedHtmlTag'], 'img');
    });

    test('applies the content policy tag lists to markdown constructs', () {
      const policy = TagflowContentPolicy(blockedTags: {'table'});

      final dropped = const TagflowMarkdownAdapter(
        policy: policy,
      ).parse('| a |\n|---|\n| 1 |\n\nafter');
      expect(dropped.children.single.kind, TagflowNodeKind.paragraph);
      expect(dropped.children.single.id, '0.1');

      final placeholder = const TagflowMarkdownAdapter(
        policy: TagflowContentPolicy(
          blockedTags: {'table'},
          unsupportedBehavior: TagflowUnsupportedBehavior.preservePlaceholder,
        ),
      ).parse('| a |\n|---|\n| 1 |');
      expect(placeholder.children.single.kind, TagflowNodeKind.unsupported);
      expect(placeholder.children.single.metadata['blockedHtmlTag'], 'table');
    });

    group('raw HTML', () {
      const markdown =
          'Press <kbd>Ctrl</kbd> and <b>go</b>.\n\n'
          '<div>\n<p>Block <em>html</em></p>\n<script>alert(1)</script>\n'
          '</div>\n\nafter';

      test('adapts raw HTML through the HTML adapter and policy', () {
        final document = adapter.parse(markdown);
        final paragraph = document.children[0];

        expect(paragraph.children.first.text, 'Press ');
        expect(paragraph.children.first.isMarkdownRawHtml, isFalse);
        final bold = paragraph.children.firstWhere(
          (node) => node.htmlTag == 'b',
        );
        expect(bold.isMarkdownRawHtml, isTrue);
        expect(bold.presentation.inlineSemantics, {
          TagflowInlineSemantic.strong,
        });
        expect(bold.source?.kind, TagflowSourceKind.html);
        expect(paragraph.children.map((node) => node.htmlTag), contains('kbd'));

        final block = document.children[1];
        expect(block.id, '0.1');
        expect(block.isMarkdownRawHtml, isTrue);
        expect(block.htmlTag, 'div');
        final allTags = [for (final node in _descendants(block)) node.htmlTag];
        expect(allTags, contains('em'));
        expect(allTags, isNot(contains('script')));
        expect(
          _descendants(block).map((node) => node.id),
          everyElement(startsWith('0.1')),
        );

        expect(document.children[2].id, '0.2');
        expect(
          () => TagflowDocument.validated(
            id: document.id,
            children: document.children,
          ),
          returnsNormally,
        );
      });

      test('drops raw HTML when configured', () {
        final document = const TagflowMarkdownAdapter(
          rawHtml: TagflowMarkdownRawHtmlBehavior.drop,
        ).parse(markdown);

        expect(document.children, hasLength(2));
        expect(
          document.children.first.children.map((node) => node.text).join(),
          'Press Ctrl and go.',
        );
        expect(
          _descendants(
            document.children.first,
          ).where((node) => node.isMarkdownRawHtml),
          isEmpty,
        );
        expect(document.children.last.id, '0.2');
      });

      test('keeps raw HTML as literal text when configured', () {
        final document = const TagflowMarkdownAdapter(
          rawHtml: TagflowMarkdownRawHtmlBehavior.text,
        ).parse(markdown);

        expect(
          document.children.first.children.map((node) => node.text).join(),
          'Press <kbd>Ctrl</kbd> and <b>go</b>.',
        );
        final block = document.children[1];
        expect(block.kind, TagflowNodeKind.paragraph);
        expect(block.isMarkdownRawHtml, isTrue);
        expect(block.children.single.text, contains('<script>'));
      });

      test('compares adapters by policy and raw HTML behavior', () {
        // Built at runtime so equality is not satisfied by const identity.
        final rawHtml = TagflowMarkdownRawHtmlBehavior.values.first;
        final runtimeAdapter = TagflowMarkdownAdapter(rawHtml: rawHtml);

        expect(runtimeAdapter, isNot(same(const TagflowMarkdownAdapter())));
        expect(runtimeAdapter, const TagflowMarkdownAdapter());
        expect(
          runtimeAdapter.hashCode,
          const TagflowMarkdownAdapter().hashCode,
        );
        expect(
          const TagflowMarkdownAdapter(),
          isNot(
            const TagflowMarkdownAdapter(
              rawHtml: TagflowMarkdownRawHtmlBehavior.drop,
            ),
          ),
        );
      });
    });
  });
}

Iterable<TagflowDocumentNode> _descendants(TagflowDocumentNode node) sync* {
  yield node;
  for (final child in node.children) {
    yield* _descendants(child);
  }
}
