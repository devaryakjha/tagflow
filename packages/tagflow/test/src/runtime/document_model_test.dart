import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

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
      expect(documentA.version, 1);
      expect(() => documentA.children.add(child), throwsUnsupportedError);
      expect(
        () => documentA.metadata.values['extra'] = true,
        throwsUnsupportedError,
      );
    });

    test('validated factory validates duplicate node ids eagerly', () {
      expect(
        () => TagflowDocument.validated(
          id: 'doc',
          children: [
            TagflowDocumentNode.paragraph(id: 'duplicate'),
            TagflowDocumentNode.container(
              id: 'section',
              children: [
                TagflowDocumentNode.text(id: 'duplicate', text: 'Collision'),
              ],
            ),
          ],
        ),
        throwsStateError,
      );
    });

    test('default constructor keeps explicit validation opt-in', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(id: 'duplicate'),
          TagflowDocumentNode.text(id: 'duplicate', text: 'Collision'),
        ],
      );

      expect(document.children, hasLength(2));
      expect(document.validateUniqueNodeIds, throwsStateError);
    });

    test('copyWith replaces document fields immutably', () {
      final original = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'paragraph')],
        metadata: TagflowMetadata(const {'origin': 'old'}),
        source: TagflowSourceInfo(kind: TagflowSourceKind.app),
      );
      final replacement = TagflowDocumentNode.heading(
        id: 'heading',
        level: 2,
        children: [
          TagflowDocumentNode.text(id: 'heading-text', text: 'Updated'),
        ],
      );

      final copied = original.copyWith(
        id: 'doc-copy',
        children: [replacement],
        metadata: TagflowMetadata(const {'origin': 'ai'}),
        source: TagflowSourceInfo(kind: TagflowSourceKind.json),
        version: 2,
      );

      expect(copied.id, 'doc-copy');
      expect(copied.children, [replacement]);
      expect(copied.metadata['origin'], 'ai');
      expect(copied.source?.kind, TagflowSourceKind.json);
      expect(copied.version, 2);
      expect(original.id, 'doc');
      expect(original.children.single.id, 'paragraph');
      expect(() => copied.children.add(replacement), throwsUnsupportedError);
    });

    test('rejects non-positive runtime schema versions', () {
      expect(
        () => TagflowDocument(id: 'doc', children: const [], version: 0),
        throwsArgumentError,
      );
      expect(
        () => TagflowDocument.validated(
          id: 'doc',
          children: const [],
          version: -1,
        ),
        throwsArgumentError,
      );

      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'paragraph')],
      );

      expect(() => document.copyWith(version: 0), throwsArgumentError);
      expect(() => document.copyWithValidated(version: 0), throwsArgumentError);
    });

    test('copyWith clears nullable document fields explicitly', () {
      final original = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'paragraph')],
        source: TagflowSourceInfo(kind: TagflowSourceKind.app),
      );

      final copied = original.copyWith(clearSource: true);

      expect(copied.source, isNull);
      expect(original.source?.kind, TagflowSourceKind.app);
      expect(
        () => original.copyWith(
          source: TagflowSourceInfo(kind: TagflowSourceKind.json),
          clearSource: true,
        ),
        throwsArgumentError,
      );
    });

    test('copyWithValidated rejects duplicate replacement node ids', () {
      final document = TagflowDocument.validated(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'paragraph')],
      );

      expect(
        () => document.copyWithValidated(
          children: [
            TagflowDocumentNode.paragraph(id: 'duplicate'),
            TagflowDocumentNode.text(id: 'duplicate', text: 'Collision'),
          ],
        ),
        throwsStateError,
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
      final descriptionList = TagflowDocumentNode.descriptionList(
        id: TagflowNodeIds.fromPath([2]),
        children: [
          TagflowDocumentNode.descriptionTerm(
            id: TagflowNodeIds.fromPath([2, 0]),
            children: [
              TagflowDocumentNode.text(
                id: TagflowNodeIds.fromPath([2, 0, 0]),
                text: 'Term',
              ),
            ],
          ),
          TagflowDocumentNode.descriptionDetails(
            id: TagflowNodeIds.fromPath([2, 1]),
            children: [
              TagflowDocumentNode.text(
                id: TagflowNodeIds.fromPath([2, 1, 0]),
                text: 'Definition',
              ),
            ],
          ),
        ],
      );
      final image = TagflowDocumentNode.image(
        id: TagflowNodeIds.fromPath([3]),
        url: Uri.parse('https://example.com/image.png'),
        alt: 'Hero image',
        width: 640,
        height: 480,
      );
      final cell = TagflowDocumentNode.tableCell(
        id: TagflowNodeIds.fromPath([4]),
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

      expect(descriptionList.kind, TagflowNodeKind.descriptionList);
      expect(
        descriptionList.children.first.kind,
        TagflowNodeKind.descriptionTerm,
      );
      expect(
        descriptionList.children.last.kind,
        TagflowNodeKind.descriptionDetails,
      );
      expect(descriptionList.children.last.children.single.text, 'Definition');

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

    test('copyWith updates typed node fields without dropping others', () {
      final child = TagflowDocumentNode.text(id: 'child', text: 'child');
      final node = TagflowDocumentNode.heading(
        id: 'heading',
        level: 1,
        children: [child],
        presentation: TagflowPresentation(
          variant: 'display',
          inlineSemantics: const {TagflowInlineSemantic.strong},
        ),
        metadata: TagflowMetadata(const {'role': 'title'}),
        source: TagflowSourceInfo(kind: TagflowSourceKind.app),
      );
      final replacementChild = TagflowDocumentNode.link(
        id: 'link',
        url: Uri.parse('https://example.com'),
        children: [
          TagflowDocumentNode.text(id: 'link-text', text: 'Read more'),
        ],
      );

      final copied = node.copyWith(
        id: 'heading-copy',
        children: [replacementChild],
        presentation: TagflowPresentation(
          variant: 'headline',
          inlineSemantics: const {TagflowInlineSemantic.emphasis},
        ),
        level: 3,
        text: 'Synthetic heading payload',
        url: Uri.parse('https://example.com/heading'),
        ordered: true,
        startIndex: 4,
        alt: 'alt text',
        width: 120,
        height: 80,
        language: 'dart',
        rowSpan: 2,
        colSpan: 3,
        header: true,
        unsupportedReason: 'custom',
      );

      expect(copied.id, 'heading-copy');
      expect(copied.kind, TagflowNodeKind.heading);
      expect(copied.children, [replacementChild]);
      expect(copied.presentation.variant, 'headline');
      expect(copied.metadata['role'], 'title');
      expect(copied.source?.kind, TagflowSourceKind.app);
      expect(copied.level, 3);
      expect(copied.text, 'Synthetic heading payload');
      expect(copied.url, Uri.parse('https://example.com/heading'));
      expect(copied.ordered, isTrue);
      expect(copied.startIndex, 4);
      expect(copied.alt, 'alt text');
      expect(copied.width, 120);
      expect(copied.height, 80);
      expect(copied.language, 'dart');
      expect(copied.rowSpan, 2);
      expect(copied.colSpan, 3);
      expect(copied.header, isTrue);
      expect(copied.unsupportedReason, 'custom');
      expect(node.id, 'heading');
      expect(node.level, 1);
      expect(node.children, [child]);
      expect(() => copied.children.add(child), throwsUnsupportedError);
    });

    test('copyWith clears nullable node payload fields explicitly', () {
      final node = TagflowDocumentNode.image(
        id: 'image',
        url: Uri.parse('https://example.com/image.png'),
        alt: 'Hero image',
        width: 640,
        height: 480,
        source: TagflowSourceInfo(kind: TagflowSourceKind.html),
      );

      final copied = node.copyWith(
        clearAlt: true,
        clearWidth: true,
        clearSource: true,
      );

      expect(copied.url, Uri.parse('https://example.com/image.png'));
      expect(copied.alt, isNull);
      expect(copied.width, isNull);
      expect(copied.height, 480);
      expect(copied.source, isNull);
      expect(node.alt, 'Hero image');
      expect(node.width, 640);
      expect(node.source?.kind, TagflowSourceKind.html);
      expect(
        () => node.copyWith(alt: 'Replacement', clearAlt: true),
        throwsArgumentError,
      );
    });
  });

  group('TagflowPresentation', () {
    test('merges typed fields, inline semantics, and hint maps immutably', () {
      final base = TagflowPresentation(
        variant: 'body',
        width: 320,
        inlineSemantics: const {TagflowInlineSemantic.strong},
        hints: const {'htmlTag': 'p', 'strong': false},
      );
      final override = TagflowPresentation(
        height: 180,
        inlineSemantics: const {TagflowInlineSemantic.emphasis},
        hints: const {'strong': true, 'className': 'lead'},
      );

      final merged = base.merge(override);

      expect(merged.variant, 'body');
      expect(merged.width, 320);
      expect(merged.height, 180);
      expect(merged.inlineSemantics, {
        TagflowInlineSemantic.strong,
        TagflowInlineSemantic.emphasis,
      });
      expect(merged.hints, {
        'htmlTag': 'p',
        'strong': true,
        'className': 'lead',
      });
      expect(
        () => merged.inlineSemantics.add(TagflowInlineSemantic.underline),
        throwsUnsupportedError,
      );
      expect(() => merged.hints['another'] = 'value', throwsUnsupportedError);
    });
  });
}
