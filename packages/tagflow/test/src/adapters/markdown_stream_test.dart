import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

const _answer = '''
# Streaming answer

Here is a paragraph with **bold**, `code` and a [link](https://example.com).

```dart
void main() {
  print('hi');

  print('after a blank line');
}
```

| Name | Value |
| :--- | ---: |
| one | 1 |
| two | 2 |

- first item
- second item
  - nested item

1. ordered
2. list

> A quote
> over two lines

---

Final words.
''';

void main() {
  const adapter = TagflowMarkdownAdapter();

  List<TagflowDocument> streamInChunks(String markdown, int size) {
    final stream = TagflowMarkdownStream();
    final documents = <TagflowDocument>[];
    for (var start = 0; start < markdown.length; start += size) {
      final end = (start + size).clamp(0, markdown.length);
      stream.add(markdown.substring(start, end));
      documents.add(stream.document);
    }
    stream.close();
    documents.add(stream.document);
    return documents;
  }

  TagflowDocument oneShot(String markdown) {
    return adapter.parse(markdown, id: 'markdown-stream');
  }

  group('TagflowMarkdownStream', () {
    test('should start with an empty document', () {
      final stream = TagflowMarkdownStream(id: 'answer');

      expect(stream.document.id, 'answer');
      expect(stream.document.children, isEmpty);
      expect(stream.document.source?.kind, TagflowSourceKind.markdown);
      expect(stream.text, isEmpty);
      expect(stream.isClosed, isFalse);
    });

    test('should close an empty stream to an empty document', () {
      final stream = TagflowMarkdownStream()..close();

      expect(stream.document, oneShot(''));
      expect(stream.isClosed, isTrue);
    });

    for (final size in [1, 2, 3, 5, 8, 13, 64]) {
      test('should equal a one-shot parse with $size-character chunks', () {
        final documents = streamInChunks(_answer, size);

        expect(documents.last, oneShot(_answer));
      });
    }

    test('should equal a one-shot parse at every prefix once closed', () {
      for (var end = 0; end <= _answer.length; end += 7) {
        final prefix = _answer.substring(0, end);
        final stream = TagflowMarkdownStream()
          ..add(prefix)
          ..close();

        expect(stream.document, oneShot(prefix), reason: 'prefix $end');
      }
    });

    // Setext headings are the exception: a paragraph line cannot know that an
    // underline follows until the next line arrives.
    test('should never change the kind of a node with 1-character chunks', () {
      final documents = streamInChunks(_answer, 1);
      final finalKinds = {
        for (final node in documents.last.children) node.id: node.kind,
      };

      for (final document in documents) {
        for (final node in document.children) {
          expect(
            node.kind,
            finalKinds[node.id],
            reason: 'node ${node.id} in ${document.children}',
          );
        }
      }
    });

    test('should keep closed block instances across updates', () {
      final stream = TagflowMarkdownStream()
        ..add('# Title\n\nFirst paragraph.\n\nSecond');
      final heading = stream.document.children[0];
      final first = stream.document.children[1];

      stream
        ..add(' paragraph keeps growing')
        ..add(' and growing.\n\n- a list')
        ..add('\n- with items\n\nDone.')
        ..close();

      expect(stream.document.children[0], same(heading));
      expect(stream.document.children[1], same(first));
      expect(heading.id, '0.0');
      expect(first.id, '0.1');
    });

    test('should only patch the open tail block', () async {
      final stream = TagflowMarkdownStream()..add('Intro.\n\nGrowing');
      final updates = <TagflowMarkdownStreamUpdate>[];
      final subscription = stream.updates.listen(updates.add);

      stream.add(' text');
      await pumpEventQueue();

      expect(updates, hasLength(1));
      expect(updates.single.patches, hasLength(1));
      expect(updates.single.document.children.first.id, '0.0');
      expect(
        updates.single.document.children.last.children.single.text,
        'Growing text',
      );
      await subscription.cancel();
      stream.dispose();
    });

    test('should rebuild the final document by replaying patches', () async {
      final stream = TagflowMarkdownStream();
      var replayed = stream.document;
      final subscription = stream.updates.listen((update) {
        replayed = replayed.applyPatches(update.patches);
      });

      for (var start = 0; start < _answer.length; start += 4) {
        final end = (start + 4).clamp(0, _answer.length);
        stream.add(_answer.substring(start, end));
      }
      stream.close();
      await pumpEventQueue();

      expect(replayed, stream.document);
      expect(replayed, oneShot(_answer));
      await subscription.cancel();
      stream.dispose();
    });

    test('should not emit an update when nothing visible changed', () {
      var notifications = 0;
      final stream = TagflowMarkdownStream()
        ..add('Hello\n\n')
        ..addListener(() => notifications++)
        ..add('`')
        ..add('`');

      expect(notifications, 0);
      expect(stream.document.children.single.kind, TagflowNodeKind.paragraph);
    });

    group('mid-stream', () {
      TagflowDocument documentFor(String markdown) {
        return (TagflowMarkdownStream()..add(markdown)).document;
      }

      test('should hold back a partial fence marker', () {
        final document = documentFor('Intro\n\n``');

        expect(document.children.single.kind, TagflowNodeKind.paragraph);
        expect(document.children.single.children.single.text, 'Intro');
      });

      test('should hold back a fence info string being typed', () {
        final document = documentFor('Intro\n\n```da');

        expect(document.children, hasLength(1));
      });

      test('should render an unclosed fence as code', () {
        final document = documentFor('```dart\nvoid main() {\n\n  print(1');

        final code = document.children.single;
        expect(code.kind, TagflowNodeKind.codeBlock);
        expect(code.language, 'dart');
        expect(code.text, 'void main() {\n\n  print(1');
      });

      test('should hold back a partial closing fence', () {
        final document = documentFor('```\ncode\n``');

        expect(document.children.single.text, 'code');
      });

      test('should hold back a table header until its delimiter row', () {
        expect(documentFor('Intro\n\n| a | b |').children, hasLength(1));
        expect(documentFor('Intro\n\n| a | b |\n').children, hasLength(1));
        expect(documentFor('Intro\n\n| a | b |\n| -').children, hasLength(1));

        final table = documentFor(
          'Intro\n\n| a | b |\n| - | - |\n| 1',
        ).children;
        expect(table.last.kind, TagflowNodeKind.table);
        expect(table.last.children, hasLength(2));
      });

      test('should hold back a bare list marker', () {
        final document = documentFor('- one\n-');

        final list = document.children.single;
        expect(list.kind, TagflowNodeKind.list);
        expect(list.children, hasLength(1));
      });

      test('should not turn a paragraph into a setext heading early', () {
        final document = documentFor('Title\n-');

        expect(document.children.single.kind, TagflowNodeKind.paragraph);
      });

      test('should show a word split across chunks once joined', () {
        final stream = TagflowMarkdownStream()
          ..add('Hel')
          ..add('lo wor')
          ..add('ld');

        expect(
          stream.document.children.single.children.single.text,
          'Hello world',
        );
      });

      test('should keep a loose list as one list', () {
        final stream = TagflowMarkdownStream()
          ..add('- one\n\n')
          ..add('- two\n\n')
          ..add('  continued\n\nAfter.\n');

        expect(stream.document.children, hasLength(2));
        expect(stream.document.children.first.children, hasLength(2));
        stream.close();
        expect(stream.document, oneShot(stream.text));
      });
    });

    test('should resolve references defined after their use on close', () {
      const markdown = 'See [docs][d].\n\nMore text.\n\n[d]: https://a.dev\n';
      final documents = streamInChunks(markdown, 3);

      expect(documents.last, oneShot(markdown));
      expect(
        documents.last.children.first.children[1].kind,
        TagflowNodeKind.link,
      );
    });

    test('should apply the adapter content policy', () {
      final stream = TagflowMarkdownStream()
        ..add('<script>alert(1)</script>\n\n')
        ..add('[x](javascript:alert(1)) ok\n')
        ..close();

      expect(
        stream.document,
        adapter.parse(stream.text, id: 'markdown-stream'),
      );
      expect(
        stream.document.children.any(
          (node) => node.kind == TagflowNodeKind.link,
        ),
        isFalse,
      );
    });

    test('should throw when adding after close', () {
      final stream = TagflowMarkdownStream()..close();

      expect(() => stream.add('late'), throwsStateError);
    });

    test('should add a Stream<String> and close when it is done', () async {
      final stream = TagflowMarkdownStream();

      await stream.addStream(Stream.fromIterable(['# Hi\n\n', 'Body']));

      expect(stream.isClosed, isTrue);
      expect(stream.document, oneShot('# Hi\n\nBody'));
    });

    test('should keep the stream open when closeOnDone is false', () async {
      final stream = TagflowMarkdownStream();

      await stream.addStream(
        Stream.fromIterable(['a', 'b']),
        closeOnDone: false,
      );

      expect(stream.isClosed, isFalse);
      expect(stream.text, 'ab');
    });
  });

  group('TagflowMarkdownStreamView', () {
    testWidgets('should render chunks as they arrive', (tester) async {
      final stream = TagflowMarkdownStream();
      addTearDown(stream.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TagflowMarkdownStreamView(stream: stream)),
        ),
      );
      stream.add('# Title\n\nHel');
      await tester.pump();

      expect(find.textContaining('Title', findRichText: true), findsOneWidget);
      expect(find.textContaining('Hel', findRichText: true), findsOneWidget);

      stream
        ..add('lo there')
        ..close();
      await tester.pump();

      expect(
        find.textContaining('Hello there', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('should keep closed block elements across updates', (
      tester,
    ) async {
      final stream = TagflowMarkdownStream()..add('# Title\n\nBody');
      addTearDown(stream.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TagflowMarkdownStreamView(stream: stream)),
        ),
      );
      final before = tester.element(find.byKey(const ValueKey('0.0')));

      stream.add(' keeps growing');
      await tester.pump();

      expect(tester.element(find.byKey(const ValueKey('0.0'))), same(before));
    });
  });

  group('TagflowDocumentPatch.appendRootChildren', () {
    test('should append top-level nodes to an empty document', () {
      final document = TagflowDocument(id: 'doc', children: const []);

      final patched = document.applyPatch(
        TagflowDocumentPatch.appendRootChildren(
          children: [TagflowDocumentNode.paragraph(id: 'p')],
        ),
      );

      expect(patched.children.single.id, 'p');
    });

    test('should reject duplicate ids', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'p')],
      );

      expect(
        () => document.applyPatch(
          TagflowDocumentPatch.appendRootChildren(
            children: [TagflowDocumentNode.paragraph(id: 'p')],
          ),
        ),
        throwsStateError,
      );
    });
  });
}
