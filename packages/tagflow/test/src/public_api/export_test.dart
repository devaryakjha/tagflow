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
    expect(adapter.policy, policy);
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
