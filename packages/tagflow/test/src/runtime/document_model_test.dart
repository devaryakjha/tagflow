import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowDocument', () {
    test('is deeply immutable and value-equal', () {
      final metadata = TagflowMetadata(const {'origin': 'cms'});
      final source = TagflowSourceInfo(
        kind: TagflowSourceKind.html,
        adapter: 'html',
        uri: Uri.parse('https://example.com/article'),
        line: 4,
        column: 2,
        metadata: TagflowMetadata(const {'htmlTag': 'article'}),
      );

      final child = TagflowDocumentNode.paragraph(
        id: TagflowNodeIds.fromPath([0]),
        children: [
          TagflowDocumentNode.text(
            id: TagflowNodeIds.fromPath([0, 0]),
            text: 'Hello world',
          ),
        ],
      );

      final documentA = TagflowDocument(
        id: 'doc-1',
        children: [child],
        metadata: metadata,
        source: source,
      );
      final documentB = TagflowDocument(
        id: 'doc-1',
        children: [
          TagflowDocumentNode.paragraph(
            id: TagflowNodeIds.fromPath([0]),
            children: [
              TagflowDocumentNode.text(
                id: TagflowNodeIds.fromPath([0, 0]),
                text: 'Hello world',
              ),
            ],
          ),
        ],
        metadata: TagflowMetadata(const {'origin': 'cms'}),
        source: TagflowSourceInfo(
          kind: TagflowSourceKind.html,
          adapter: 'html',
          uri: Uri.parse('https://example.com/article'),
          line: 4,
          column: 2,
          metadata: TagflowMetadata(const {'htmlTag': 'article'}),
        ),
      );

      expect(documentA, documentB);
      expect(documentA.hashCode, documentB.hashCode);
      expect(() => documentA.children.add(child), throwsUnsupportedError);
      expect(
        () => documentA.metadata.values['extra'] = true,
        throwsUnsupportedError,
      );
    });
  });

  group('TagflowDocumentNode', () {
    test('constructs semantic nodes with typed fields', () {
      final heading = TagflowDocumentNode.heading(
        id: TagflowNodeIds.fromPath([0]),
        level: 2,
        children: [
          TagflowDocumentNode.text(
            id: TagflowNodeIds.fromPath([0, 0]),
            text: 'Section title',
          ),
        ],
        presentation: TagflowPresentation(
          variant: 'display',
          hints: const {'htmlTag': 'h2'},
        ),
      );
      final list = TagflowDocumentNode.list(
        id: TagflowNodeIds.fromPath([1]),
        ordered: true,
        startIndex: 3,
        children: [
          TagflowDocumentNode.listItem(
            id: TagflowNodeIds.fromPath([1, 0]),
            children: [
              TagflowDocumentNode.text(
                id: TagflowNodeIds.fromPath([1, 0, 0]),
                text: 'First item',
              ),
            ],
          ),
        ],
      );
      final image = TagflowDocumentNode.image(
        id: TagflowNodeIds.fromPath([2]),
        url: Uri.parse('https://example.com/image.png'),
        alt: 'Hero image',
        width: 640,
        height: 480,
      );
      final cell = TagflowDocumentNode.tableCell(
        id: TagflowNodeIds.fromPath([3]),
        rowSpan: 2,
        colSpan: 3,
        header: true,
      );

      expect(heading.kind, TagflowNodeKind.heading);
      expect(heading.level, 2);
      expect(heading.presentation.variant, 'display');
      expect(heading.presentation.hints['htmlTag'], 'h2');

      expect(list.kind, TagflowNodeKind.list);
      expect(list.ordered, isTrue);
      expect(list.startIndex, 3);

      expect(image.kind, TagflowNodeKind.image);
      expect(image.url, Uri.parse('https://example.com/image.png'));
      expect(image.alt, 'Hero image');
      expect(image.width, 640);
      expect(image.height, 480);

      expect(cell.kind, TagflowNodeKind.tableCell);
      expect(cell.rowSpan, 2);
      expect(cell.colSpan, 3);
      expect(cell.header, isTrue);
    });

    test('uses deterministic path-based stable ids', () {
      expect(TagflowNodeIds.root, '0');
      expect(TagflowNodeIds.fromPath([]), '0');
      expect(TagflowNodeIds.fromPath([1, 3, 2]), '0.1.3.2');
      expect(
        TagflowNodeIds.fromPath([1, 3, 2]),
        TagflowNodeIds.fromPath([1, 3, 2]),
      );
    });
  });

  group('TagflowPresentation', () {
    test('merges typed fields and hint maps immutably', () {
      final base = TagflowPresentation(
        variant: 'body',
        width: 320,
        hints: const {'htmlTag': 'p', 'strong': false},
      );
      final override = TagflowPresentation(
        height: 180,
        hints: const {'strong': true, 'className': 'lead'},
      );

      final merged = base.merge(override);

      expect(merged.variant, 'body');
      expect(merged.width, 320);
      expect(merged.height, 180);
      expect(merged.hints, {
        'htmlTag': 'p',
        'strong': true,
        'className': 'lead',
      });
      expect(() => merged.hints['another'] = 'value', throwsUnsupportedError);
    });
  });
}
