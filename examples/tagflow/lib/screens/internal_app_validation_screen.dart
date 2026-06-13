import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

final _validationDocument = TagflowDocument(
  id: 'internal-margin-update',
  children: [
    TagflowDocumentNode.heading(
      id: 'internal-margin-update.title',
      level: 1,
      children: [
        TagflowDocumentNode.text(
          id: 'internal-margin-update.title.text',
          text: 'June margin update',
        ),
      ],
    ),
    TagflowDocumentNode.paragraph(
      id: 'internal-margin-update.summary',
      children: [
        TagflowDocumentNode.text(
          id: 'internal-margin-update.summary.0',
          text: 'The new risk model applies ',
        ),
        TagflowDocumentNode.text(
          id: 'internal-margin-update.summary.1',
          text: 'higher intraday margin',
          presentation: TagflowPresentation(
            inlineSemantics: const {TagflowInlineSemantic.strong},
          ),
        ),
        TagflowDocumentNode.text(
          id: 'internal-margin-update.summary.2',
          text: ' to volatile contracts and keeps delivery trades unchanged.',
        ),
      ],
    ),
    TagflowDocumentNode.paragraph(
      id: 'internal-margin-update.policy',
      children: [
        TagflowDocumentNode.text(
          id: 'internal-margin-update.policy.0',
          text: 'Review the ',
        ),
        TagflowDocumentNode.link(
          id: 'internal-margin-update.policy.link',
          url: Uri.parse('app://policy/margin-checklist'),
          children: [
            TagflowDocumentNode.text(
              id: 'internal-margin-update.policy.link.text',
              text: 'policy checklist',
            ),
          ],
        ),
        TagflowDocumentNode.text(
          id: 'internal-margin-update.policy.1',
          text: ' before enabling the CMS rollout flag.',
        ),
      ],
    ),
    TagflowDocumentNode.list(
      id: 'internal-margin-update.checks',
      ordered: false,
      children: [
        TagflowDocumentNode.listItem(
          id: 'internal-margin-update.checks.0',
          children: [
            TagflowDocumentNode.paragraph(
              id: 'internal-margin-update.checks.0.body',
              children: [
                TagflowDocumentNode.text(
                  id: 'internal-margin-update.checks.0.body.text',
                  text: 'Show the change only to eligible accounts.',
                ),
              ],
            ),
          ],
        ),
        TagflowDocumentNode.listItem(
          id: 'internal-margin-update.checks.1',
          children: [
            TagflowDocumentNode.paragraph(
              id: 'internal-margin-update.checks.1.body',
              children: [
                TagflowDocumentNode.text(
                  id: 'internal-margin-update.checks.1.body.text',
                  text: 'Keep support copy selectable for escalation notes.',
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    TagflowDocumentNode.table(
      id: 'internal-margin-update.table',
      children: [
        TagflowDocumentNode.tableRow(
          id: 'internal-margin-update.table.header',
          children: [
            _tableCell(
              id: 'internal-margin-update.table.header.segment',
              text: 'Segment',
              header: true,
            ),
            _tableCell(
              id: 'internal-margin-update.table.header.policy',
              text: 'Policy',
              header: true,
            ),
            _tableCell(
              id: 'internal-margin-update.table.header.status',
              text: 'Status',
              header: true,
            ),
          ],
        ),
        TagflowDocumentNode.tableRow(
          id: 'internal-margin-update.table.fno',
          children: [
            _tableCell(
              id: 'internal-margin-update.table.fno.segment',
              text: 'F&O',
            ),
            _tableCell(
              id: 'internal-margin-update.table.fno.policy',
              text: '2.5x intraday buffer',
            ),
            _tableCell(
              id: 'internal-margin-update.table.fno.status',
              text: 'Pilot',
            ),
          ],
        ),
        TagflowDocumentNode.tableRow(
          id: 'internal-margin-update.table.equity',
          children: [
            _tableCell(
              id: 'internal-margin-update.table.equity.segment',
              text: 'Equity',
            ),
            _tableCell(
              id: 'internal-margin-update.table.equity.policy',
              text: 'No delivery change',
            ),
            _tableCell(
              id: 'internal-margin-update.table.equity.status',
              text: 'Ready',
            ),
          ],
        ),
      ],
    ),
    TagflowDocumentNode.codeBlock(
      id: 'internal-margin-update.code',
      language: 'yaml',
      text: 'rollout:\n  audience: eligible_accounts\n  fallback: legacy_copy',
    ),
    TagflowDocumentNode.image(
      id: 'internal-margin-update.chart',
      url: Uri.parse('tagflow-internal://media/margin-impact-chart'),
      alt: 'Margin impact chart',
      width: 560,
      height: 180,
    ),
    TagflowDocumentNode.unsupported(
      id: 'internal-margin-update.rating-widget',
      unsupportedReason: 'interactive-rating-widget',
    ),
  ],
);

const _controlledHtmlProbe = '''
<section>
  <h2>Controlled HTML probe</h2>
  <p>Allowed content keeps a <a href="https://example.com/policy">safe policy link</a>.</p>
  <p>Unsafe input keeps text but blocks <a href="javascript:alert(1)">script links</a>.</p>
  <img src="https://example.com/blocked-hero.png" alt="Blocked remote hero">
  <script>window.alert('blocked');</script>
</section>
''';

TagflowDocumentNode _tableCell({
  required String id,
  required String text,
  bool header = false,
}) {
  return TagflowDocumentNode.tableCell(
    id: id,
    header: header,
    children: [TagflowDocumentNode.text(id: '$id.text', text: text)],
  );
}

class InternalAppValidationScreen extends StatefulWidget {
  const InternalAppValidationScreen({super.key});

  @override
  State<InternalAppValidationScreen> createState() =>
      _InternalAppValidationScreenState();
}

class _InternalAppValidationScreenState
    extends State<InternalAppValidationScreen> {
  String? _lastLink;

  late final TagflowComponentRegistry _registry = TagflowComponentRegistry(
    extensions: [
      tagflowTableComponents(
        treatFirstRowAsHeader: true,
        padding: const EdgeInsets.all(4),
        columnSpacing: 8,
        rowSpacing: 6,
      ),
    ],
    overrides: {
      TagflowNodeKind.image: _renderImagePlaceholder,
      TagflowNodeKind.link: _renderAppLink,
      TagflowNodeKind.unsupported: _renderUnsupportedPlaceholder,
    },
  );

  void _recordLink(String url, Object? attributes) {
    setState(() {
      _lastLink = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    final nativeViewOptions = TagflowViewOptions(
      linkTapCallback: _recordLink,
      maxImageWidth: 360,
      maxImageHeight: 180,
    );
    final selectableHtmlViewOptions = nativeViewOptions.copyWith(
      selectable: const TagflowSelectableOptions(enabled: true),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Internal App Validation')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_lastLink != null) ...[
            Text(
              'Last link: $_lastLink',
              key: const ValueKey('internal-validation-last-link'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 16),
          ],
          Tagflow.document(
            _validationDocument,
            registry: _registry,
            viewOptions: nativeViewOptions,
          ),
          const Divider(height: 32),
          Tagflow.html(
            html: _controlledHtmlProbe,
            adapter: const TagflowHtmlAdapter(
              policy: TagflowContentPolicy(
                allowRemoteImages: false,
                allowRelativeUrls: false,
                allowedSchemes: {'https', 'mailto'},
                unsupportedBehavior:
                    TagflowUnsupportedBehavior.preservePlaceholder,
              ),
            ),
            viewOptions: selectableHtmlViewOptions,
          ),
        ],
      ),
    );
  }

  Widget _renderImagePlaceholder(
    TagflowComponentContext context,
    TagflowDocumentNode node,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: node.alt,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context.buildContext).dividerColor,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context.buildContext).colorScheme.surfaceContainer,
          ),
          child: SizedBox(
            width: 360,
            height: 128,
            child: Center(
              child: Text(
                'Image placeholder: ${node.alt ?? node.url}',
                key: const ValueKey('internal-validation-image-placeholder'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderAppLink(
    TagflowComponentContext context,
    TagflowDocumentNode node,
  ) {
    return TextButton(
      onPressed: node.url == null
          ? null
          : () {
              TagflowViewOptions.of(
                context.buildContext,
              ).linkTapCallback?.call(node.url.toString(), null);
            },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(_textContent(node)),
    );
  }

  Widget _renderUnsupportedPlaceholder(
    TagflowComponentContext context,
    TagflowDocumentNode node,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Unsupported content hidden: ${node.unsupportedReason ?? 'unknown'}',
        key: const ValueKey('internal-validation-unsupported-placeholder'),
        style: Theme.of(context.buildContext).textTheme.bodySmall,
      ),
    );
  }
}

String _textContent(TagflowDocumentNode node) {
  final buffer = StringBuffer(node.text ?? '');
  for (final child in node.children) {
    buffer.write(_textContent(child));
  }
  return buffer.toString();
}
