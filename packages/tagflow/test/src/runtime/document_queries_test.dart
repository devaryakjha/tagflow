import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('TagflowDocumentQueries', () {
    test('finds a root node by id', () {
      final root = TagflowDocumentNode.paragraph(id: 'root');
      final document = TagflowDocument(id: 'doc', children: [root]);

      expect(document.nodeById('root'), same(root));
      expect(document.containsNodeId('root'), isTrue);
    });

    test('finds a nested node by id', () {
      final nested = TagflowDocumentNode.text(id: 'nested', text: 'Hello');
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.container(
            id: 'section',
            children: [
              TagflowDocumentNode.paragraph(
                id: 'paragraph',
                children: [nested],
              ),
            ],
          ),
        ],
      );

      expect(document.nodeById('nested'), same(nested));
      expect(document.containsNodeId('nested'), isTrue);
    });

    test('returns null and false for a missing id', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [TagflowDocumentNode.paragraph(id: 'known')],
      );

      expect(document.nodeById('missing'), isNull);
      expect(document.containsNodeId('missing'), isFalse);
    });

    test('fails validation for duplicate root and nested ids', () {
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(id: 'duplicate'),
          TagflowDocumentNode.container(
            id: 'section',
            children: [
              TagflowDocumentNode.paragraph(
                id: 'nested',
                children: [
                  TagflowDocumentNode.text(id: 'duplicate', text: 'collision'),
                ],
              ),
            ],
          ),
        ],
      );

      expect(document.validateUniqueNodeIds, throwsStateError);
    });
  });
}
