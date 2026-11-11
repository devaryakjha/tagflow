import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

TagflowDocumentNode _text(String id) {
  return TagflowDocumentNode.text(id: '$id.t', text: id);
}

/// One node of every [TagflowNodeKind].
Map<TagflowNodeKind, TagflowDocumentNode> _nodes() {
  final url = Uri.parse('https://example.com/a.png');
  final nodes = <TagflowNodeKind, TagflowDocumentNode>{
    TagflowNodeKind.root: TagflowDocumentNode.root(
      id: 'root',
      children: [_text('root')],
    ),
    TagflowNodeKind.container: TagflowDocumentNode.container(
      id: 'container',
      children: [_text('container')],
    ),
    TagflowNodeKind.paragraph: TagflowDocumentNode.paragraph(
      id: 'paragraph',
      children: [
        _text('paragraph'),
        TagflowDocumentNode.link(
          id: 'inline-link',
          url: url,
          children: [_text('inline-link')],
        ),
      ],
    ),
    TagflowNodeKind.heading: TagflowDocumentNode.heading(
      id: 'heading',
      level: 2,
      children: [_text('heading')],
    ),
    TagflowNodeKind.text: _text('text'),
    TagflowNodeKind.link: TagflowDocumentNode.link(
      id: 'link',
      url: url,
      children: [_text('link')],
    ),
    TagflowNodeKind.list: TagflowDocumentNode.list(
      id: 'list',
      ordered: false,
      children: [
        TagflowDocumentNode.listItem(id: 'list.0', children: [_text('list')]),
      ],
    ),
    TagflowNodeKind.listItem: TagflowDocumentNode.listItem(
      id: 'listItem',
      children: [_text('listItem')],
    ),
    TagflowNodeKind.descriptionList: TagflowDocumentNode.descriptionList(
      id: 'descriptionList',
      children: [_text('descriptionList')],
    ),
    TagflowNodeKind.descriptionTerm: TagflowDocumentNode.descriptionTerm(
      id: 'descriptionTerm',
      children: [_text('descriptionTerm')],
    ),
    TagflowNodeKind.descriptionDetails: TagflowDocumentNode.descriptionDetails(
      id: 'descriptionDetails',
      children: [_text('descriptionDetails')],
    ),
    TagflowNodeKind.blockquote: TagflowDocumentNode.blockquote(
      id: 'blockquote',
      children: [_text('blockquote')],
    ),
    TagflowNodeKind.codeBlock: TagflowDocumentNode.codeBlock(
      id: 'codeBlock',
      text: 'codeBlock',
    ),
    TagflowNodeKind.inlineCode: TagflowDocumentNode.inlineCode(
      id: 'inlineCode',
      text: 'inlineCode',
    ),
    TagflowNodeKind.image: TagflowDocumentNode.image(
      id: 'image',
      url: url,
      width: 10,
      height: 10,
    ),
    TagflowNodeKind.table: TagflowDocumentNode.table(
      id: 'table',
      children: [
        TagflowDocumentNode.tableRow(
          id: 'table.0',
          children: [
            TagflowDocumentNode.tableCell(
              id: 'table.0.0',
              children: [_text('table')],
            ),
          ],
        ),
      ],
    ),
    TagflowNodeKind.tableRow: TagflowDocumentNode.tableRow(
      id: 'tableRow',
      children: [
        TagflowDocumentNode.tableCell(
          id: 'tableRow.0',
          children: [_text('tableRow')],
        ),
      ],
    ),
    TagflowNodeKind.tableCell: TagflowDocumentNode.tableCell(
      id: 'tableCell',
      children: [_text('tableCell')],
    ),
    TagflowNodeKind.horizontalRule: TagflowDocumentNode.horizontalRule(
      id: 'horizontalRule',
    ),
    TagflowNodeKind.unsupported: TagflowDocumentNode.unsupported(
      id: 'unsupported',
      unsupportedReason: 'test',
    ),
  };
  return nodes;
}

void main() {
  testWidgets('should render every node kind through the registry without a '
      'Tagflow widget', (tester) async {
    final nodes = _nodes();
    expect(nodes.keys.toSet(), TagflowNodeKind.values.toSet());

    final registry = TagflowComponentRegistry();
    for (final entry in nodes.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Builder(
                builder: (context) => registry.render(context, entry.value),
              ),
            ),
          ),
        ),
      );

      // Tests have no network, so the image fails to load. That is reported
      // as a load error, not as a missing scope.
      expect(
        tester.takeException(),
        anyOf(isNull, isA<NetworkImageLoadException>()),
        reason: '${entry.key}',
      );
    }
  });
}
