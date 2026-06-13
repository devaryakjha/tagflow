import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';
import 'package:tagflow_table/tagflow_table.dart';

final _initialBrief = TagflowDocument(
  id: 'release-brief',
  metadata: TagflowMetadata(const {
    'route': 'reference_app_route',
    'source': 'demo_cms',
  }),
  children: [
    TagflowDocumentNode.heading(
      id: 'release-brief.title',
      level: 1,
      children: [
        TagflowDocumentNode.text(
          id: 'release-brief.title.text',
          text: 'Release readiness brief',
        ),
      ],
    ),
    TagflowDocumentNode.paragraph(
      id: 'release-brief.summary',
      children: [
        TagflowDocumentNode.text(
          id: 'release-brief.summary.0',
          text: 'Native rich content lets this app render ',
        ),
        TagflowDocumentNode.text(
          id: 'release-brief.summary.1',
          text: 'structured CMS payloads',
          presentation: TagflowPresentation(
            inlineSemantics: const {TagflowInlineSemantic.strong},
          ),
        ),
        TagflowDocumentNode.text(
          id: 'release-brief.summary.2',
          text: ' without handing layout to a web view.',
        ),
      ],
    ),
    TagflowDocumentNode.paragraph(
      id: 'release-brief.owner-note',
      children: [
        TagflowDocumentNode.text(
          id: 'release-brief.owner-note.0',
          text: 'Open the ',
        ),
        TagflowDocumentNode.link(
          id: 'release-brief.owner-note.link',
          url: Uri.parse('app://brief/release-checklist'),
          children: [
            TagflowDocumentNode.text(
              id: 'release-brief.owner-note.link.text',
              text: 'release checklist',
            ),
          ],
        ),
        TagflowDocumentNode.text(
          id: 'release-brief.owner-note.1',
          text: ' before enabling the rollout flag.',
        ),
      ],
    ),
    TagflowDocumentNode.table(
      id: 'release-brief.table',
      children: [
        TagflowDocumentNode.tableRow(
          id: 'release-brief.table.header',
          children: [
            _cell('release-brief.table.header.surface', 'Surface', true),
            _cell('release-brief.table.header.status', 'Status', true),
            _cell('release-brief.table.header.owner', 'Owner', true),
          ],
        ),
        TagflowDocumentNode.tableRow(
          id: 'release-brief.table.article',
          children: [
            _cell('release-brief.table.article.surface', 'Article detail'),
            _cell('release-brief.table.article.status', 'Ready'),
            _cell('release-brief.table.article.owner', 'Content'),
          ],
        ),
        TagflowDocumentNode.tableRow(
          id: 'release-brief.table.alerts',
          children: [
            _cell('release-brief.table.alerts.surface', 'Alerts'),
            _cell('release-brief.table.alerts.status', 'Pilot'),
            _cell('release-brief.table.alerts.owner', 'Risk'),
          ],
        ),
      ],
    ),
    TagflowDocumentNode.list(
      id: 'release-brief.checks',
      ordered: false,
      children: [
        _checkItem(
          'release-brief.checks.links',
          'Route app links through the host application.',
        ),
        _checkItem(
          'release-brief.checks.images',
          'Render media with app-owned placeholders and limits.',
        ),
      ],
    ),
    TagflowDocumentNode.image(
      id: 'release-brief.hero',
      url: Uri.parse('tagflow-demo://media/release-brief-chart'),
      alt: 'Release brief chart',
      width: 480,
      height: 160,
    ),
    TagflowDocumentNode.unsupported(
      id: 'release-brief.poll',
      unsupportedReason: 'interactive-poll',
    ),
  ],
);

const _htmlBulletin = '''
<article>
  <h2>CMS bulletin</h2>
  <p>The public route also accepts controlled HTML for legacy content.</p>
  <ul>
    <li>Allowed links stay tappable.</li>
    <li>Script links and remote images are blocked by policy.</li>
  </ul>
  <p><a href="https://example.com/release-notes">View release notes</a></p>
  <p><a href="javascript:alert(1)">Unsafe action</a></p>
  <img src="https://example.com/remote.png" alt="Remote chart">
</article>
''';

TagflowDocumentNode _cell(String id, String text, [bool header = false]) {
  return TagflowDocumentNode.tableCell(
    id: id,
    header: header,
    children: [TagflowDocumentNode.text(id: '$id.text', text: text)],
  );
}

TagflowDocumentNode _checkItem(String id, String text) {
  return TagflowDocumentNode.listItem(
    id: id,
    children: [
      TagflowDocumentNode.paragraph(
        id: '$id.body',
        children: [TagflowDocumentNode.text(id: '$id.body.text', text: text)],
      ),
    ],
  );
}

class ReferenceAppRouteScreen extends StatefulWidget {
  const ReferenceAppRouteScreen({super.key});

  @override
  State<ReferenceAppRouteScreen> createState() =>
      _ReferenceAppRouteScreenState();
}

class _ReferenceAppRouteScreenState extends State<ReferenceAppRouteScreen> {
  late TagflowDocument _document;
  String _revision = 'cms-rev-1';
  String? _lastLink;

  late final TagflowComponentRegistry _registry = TagflowComponentRegistry(
    extensions: [
      tagflowTableComponents(
        treatFirstRowAsHeader: true,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        columnSpacing: 10,
        rowSpacing: 6,
      ),
    ],
    overrides: {
      TagflowNodeKind.image: _renderImagePlaceholder,
      TagflowNodeKind.link: _renderAppLink,
      TagflowNodeKind.unsupported: _renderUnsupportedPlaceholder,
    },
  );

  @override
  void initState() {
    super.initState();
    _document = _initialBrief;
  }

  void _applyCmsUpdate() {
    setState(() {
      _document = _document.applyPatches([
        TagflowDocumentPatch.replaceNode(
          nodeId: 'release-brief.summary',
          node: TagflowDocumentNode.paragraph(
            id: 'release-brief.summary',
            children: [
              TagflowDocumentNode.text(
                id: 'release-brief.summary.updated',
                text: 'CMS update received: the alert surface is now ready.',
              ),
            ],
          ),
        ),
        TagflowDocumentPatch.appendChildren(
          parentNodeId: 'release-brief.checks',
          children: [
            _checkItem(
              'release-brief.checks.audit',
              'Record the reviewer-visible route evidence in the package repo.',
            ),
          ],
        ),
      ]);
      _revision = 'cms-rev-2';
    });
  }

  void _recordLink(String url, Object? attributes) {
    setState(() {
      _lastLink = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewOptions = TagflowViewOptions(
      linkTapCallback: _recordLink,
      maxImageWidth: 360,
      maxImageHeight: 160,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reference App Route')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Revision: $_revision',
            key: const ValueKey('reference-route-revision'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          if (_lastLink != null) ...[
            const SizedBox(height: 8),
            Text(
              'Last link: $_lastLink',
              key: const ValueKey('reference-route-last-link'),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              key: const ValueKey('reference-route-apply-update'),
              onPressed: _revision == 'cms-rev-2' ? null : _applyCmsUpdate,
              child: const Text('Apply CMS update'),
            ),
          ),
          const SizedBox(height: 16),
          Tagflow.document(
            _document,
            registry: _registry,
            viewOptions: viewOptions,
          ),
          const Divider(height: 32),
          Tagflow.html(
            html: _htmlBulletin,
            adapter: const TagflowHtmlAdapter(
              policy: TagflowContentPolicy(
                allowRemoteImages: false,
                allowRelativeUrls: false,
                allowedSchemes: {'https', 'mailto'},
                unsupportedBehavior:
                    TagflowUnsupportedBehavior.preservePlaceholder,
              ),
            ),
            registry: _registry,
            viewOptions: viewOptions.copyWith(
              selectable: const TagflowSelectableOptions(enabled: true),
            ),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context.buildContext).dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 360,
          height: 112,
          child: Center(
            child: Text(
              'Media: ${node.alt ?? 'placeholder'}',
              key: const ValueKey('reference-route-image-placeholder'),
              textAlign: TextAlign.center,
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
      child: Text(_plainText(node)),
    );
  }

  Widget _renderUnsupportedPlaceholder(
    TagflowComponentContext context,
    TagflowDocumentNode node,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        'Unsupported: ${node.unsupportedReason ?? 'unknown'}',
        key: const ValueKey('reference-route-unsupported-placeholder'),
        style: Theme.of(context.buildContext).textTheme.bodySmall,
      ),
    );
  }
}

String _plainText(TagflowDocumentNode node) {
  final buffer = StringBuffer(node.text ?? '');
  for (final child in node.children) {
    buffer.write(_plainText(child));
  }
  return buffer.toString();
}
