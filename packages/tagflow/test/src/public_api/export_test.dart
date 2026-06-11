import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart' as legacy;
import 'package:tagflow/tagflow.dart' as api;

void main() {
  test('tagflow.dart exports the alpha-facing runtime API', () {
    final document = api.TagflowDocument(
      id: 'doc',
      children: [
        api.TagflowDocumentNode.paragraph(
          id: 'paragraph',
          children: [api.TagflowDocumentNode.text(id: 'text', text: 'Hello')],
        ),
      ],
    );
    const adapter = api.TagflowHtmlAdapter();
    final nativeDocument = api.TagflowNativeBlockDocument(
      id: 'native-doc',
      schemaVersion: 1,
      blocks: [
        api.TagflowNativeBlock.callout(
          id: 'native-callout',
          variant: 'tip',
          children: [
            api.TagflowNativeBlock.table(
              id: 'native-table',
              children: [
                api.TagflowNativeBlock.tableRow(
                  id: 'native-row',
                  children: [
                    api.TagflowNativeBlock.tableCell(id: 'native-cell'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
    const nativeAdapter = api.TagflowNativeBlockAdapter();
    final nativePatch = api.TagflowNativeBlockPatch.appendChildren(
      parentNodeId: 'paragraph',
      children: [api.TagflowNativeBlock.paragraph(id: 'native-child')],
    );
    const nodeIdStrategy = api.TagflowHtmlNodeIdStrategy.attribute(
      attribute: 'data-node-id',
      fallbackToPath: false,
    );
    const policy = api.TagflowContentPolicy.defaults;
    final registry = api.TagflowComponentRegistry.components(
      components: {
        api.TagflowNodeKind.paragraph: (context, node) {
          return const Text('override');
        },
      },
    );
    const theme = api.TagflowTheme.raw(
      styles: {},
      defaultStyle: api.TagflowStyle.empty,
    );

    expect(document.children.single.kind, api.TagflowNodeKind.paragraph);
    expect(document.nodeById('paragraph'), same(document.children.single));
    expect(document.containsNodeId('text'), isTrue);
    document.validateUniqueNodeIds();
    expect(adapter.policy, policy);
    expect(
      nativeAdapter.adapt(nativeDocument).children.single.id,
      'native-callout',
    );
    expect(
      nativeDocument.blocks.single.kind,
      api.TagflowNativeBlockKind.callout,
    );
    expect(
      nativeDocument.blocks.single.children.single.kind,
      api.TagflowNativeBlockKind.table,
    );
    expect(
      document
          .applyPatch(nativeAdapter.adaptPatch(nativePatch))
          .children
          .single
          .children
          .last
          .id,
      'native-child',
    );
    expect(nodeIdStrategy.attribute, 'data-node-id');
    expect(nodeIdStrategy.fallbackToPath, isFalse);
    expect(registry.hasComponent(api.TagflowNodeKind.paragraph), isTrue);
    expect(theme.defaultStyle, api.TagflowStyle.empty);
    expect(api.TagflowViewOptions.defaults, isA<api.TagflowViewOptions>());
    expect(api.StyleParser.parseSize('12px'), 12);
  });

  test('legacy.dart keeps compatibility APIs available', () {
    const parser = legacy.TagflowParser();
    const element = legacy.TagflowElement(tag: 'p');

    expect(parser, isA<legacy.TagflowParser>());
    expect(element, isA<legacy.TagflowNode>());
    expect(_LegacyParagraphConverter(), isA<legacy.ElementConverter>());
  });
}

final class _LegacyParagraphConverter
    extends legacy.ElementConverter<legacy.TagflowElement> {
  @override
  Set<String> get supportedTags => const {'p'};

  @override
  Widget convert(
    legacy.TagflowElement element,
    BuildContext context,
    legacy.TagflowConverter converter,
  ) {
    return const Text('legacy');
  }
}
