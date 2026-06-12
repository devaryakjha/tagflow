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
        api.TagflowDocumentNode.descriptionList(
          id: 'glossary',
          children: [
            api.TagflowDocumentNode.descriptionTerm(id: 'glossary.term'),
            api.TagflowDocumentNode.descriptionDetails(id: 'glossary.details'),
          ],
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
            api.TagflowNativeBlock.descriptionList(
              id: 'native-glossary',
              children: [
                api.TagflowNativeBlock.descriptionTerm(
                  id: 'native-glossary.term',
                ),
                api.TagflowNativeBlock.descriptionDetails(
                  id: 'native-glossary.details',
                ),
              ],
            ),
          ],
        ),
      ],
    );
    const nativeAdapter = api.TagflowNativeBlockAdapter();
    const nativeCodec = api.TagflowNativeBlockCodec();
    final nativePatch = api.TagflowNativeBlockPatch.appendChildren(
      parentNodeId: 'paragraph',
      children: [api.TagflowNativeBlock.paragraph(id: 'native-child')],
    );
    final nativePatchEnvelope = api.TagflowNativeBlockPatchEnvelope(
      documentId: 'native-doc',
      schemaVersion: 1,
      operations: [nativePatch],
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
    final viewOptions = api.TagflowViewOptions(
      nodeTapCallback: (details) {},
      tapTargetKinds: const {api.TagflowNodeKind.container},
    );
    void nodeTapCallback(api.TagflowNodeTapDetails details) {}
    final legacyOptions = api.TagflowOptions.fromViewOptions(viewOptions);
    const theme = api.TagflowTheme.raw(
      styles: {},
      defaultStyle: api.TagflowStyle.empty,
    );

    expect(document.children.first.kind, api.TagflowNodeKind.paragraph);
    expect(document.children.last.kind, api.TagflowNodeKind.descriptionList);
    expect(
      api.TagflowDocument.validated(
        id: 'validated-doc',
        children: const [],
      ).children,
      isEmpty,
    );
    expect(document.nodeById('paragraph'), same(document.children.first));
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
      nativeDocument.blocks.single.children.first.kind,
      api.TagflowNativeBlockKind.table,
    );
    expect(
      nativeDocument.blocks.single.children.last.kind,
      api.TagflowNativeBlockKind.descriptionList,
    );
    expect(nativeCodec.encodeDocument(nativeDocument)['id'], 'native-doc');
    expect(
      nativeCodec.encodePatchEnvelope(nativePatchEnvelope)['operations'],
      isNotEmpty,
    );
    expect(
      document
          .applyPatch(nativeAdapter.adaptPatch(nativePatch))
          .children
          .first
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
    expect(viewOptions.nodeTapCallback, isNotNull);
    expect(viewOptions.tapTargetKinds, contains(api.TagflowNodeKind.container));
    expect(legacyOptions.nodeTapCallback, same(viewOptions.nodeTapCallback));
    expect(legacyOptions.tapTargetKinds, viewOptions.tapTargetKinds);
    expect(legacyOptions.toViewOptions().nodeTapCallback, isNotNull);
    expect(
      legacyOptions.toViewOptions().tapTargetKinds,
      contains(api.TagflowNodeKind.container),
    );
    expect(nodeTapCallback, isA<api.TagflowNodeTapCallback>());
    expect(api.Display.block, api.Display.block);
    expect(const api.SizeValue(12).value, 12);
    expect(api.StyleParser.parseDisplay('flex'), api.Display.flex);
    expect(
      api.StyleParser.parseFlexDirection('row-reverse'),
      api.FlexDirection.rowReverse,
    );
    expect(
      api.StyleParser.parseJustifyContent('space-around'),
      api.JustifyContent.spaceAround,
    );
    expect(api.StyleParser.parseAlignItems('stretch'), api.AlignItems.stretch);
    expect(api.StyleParser.parseSize('12px'), 12);
  });

  test('legacy.dart keeps compatibility APIs available', () {
    const parser = legacy.TagflowParser();
    const element = legacy.TagflowElement(tag: 'p');
    final document = legacy.TagflowDocument(
      id: 'doc',
      children: [
        legacy.TagflowDocumentNode.paragraph(
          id: 'paragraph',
          children: [
            legacy.TagflowDocumentNode.text(id: 'text', text: 'Bridge'),
          ],
        ),
      ],
    );
    final legacyNode = legacy.TagflowHtmlDocumentBridge.toLegacyNode(document);

    expect(parser, isA<legacy.TagflowParser>());
    expect(element, isA<legacy.TagflowNode>());
    expect(_LegacyParagraphConverter(), isA<legacy.ElementConverter>());
    expect(legacyNode, isA<legacy.TagflowElement>());
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
