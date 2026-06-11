import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

const _codec = TagflowNativeBlockCodec();
const _adapter = TagflowNativeBlockAdapter();

final Map<String, Object?> _nativeJsonDocument = {
  'id': 'risk-update',
  'schemaVersion': 1,
  'revision': 'cms-rev-17',
  'source': {
    'kind': 'json',
    'adapter': 'native_block_v1',
    'uri': 'cms://announcements/risk-update',
  },
  'metadata': {'surface': 'announcement_detail', 'locale': 'en-IN'},
  'blocks': [
    {
      'id': 'risk-update.title',
      'kind': 'heading',
      'attributes': {'level': 1},
      'children': [
        {
          'id': 'risk-update.title.text',
          'kind': 'text',
          'text': 'Risk controls update',
        },
      ],
    },
    {
      'id': 'risk-update.summary',
      'kind': 'paragraph',
      'children': [
        {
          'id': 'risk-update.summary.text',
          'kind': 'text',
          'text': 'New order checks apply to equity and F&O baskets.',
        },
      ],
    },
    {
      'id': 'risk-update.actions',
      'kind': 'list',
      'attributes': {'ordered': false},
      'children': [
        {
          'id': 'risk-update.actions.review',
          'kind': 'listItem',
          'children': [
            {
              'id': 'risk-update.actions.review.body',
              'kind': 'paragraph',
              'children': [
                {
                  'id': 'risk-update.actions.review.body.text',
                  'kind': 'text',
                  'text': 'Review the risk desk checklist.',
                },
              ],
            },
          ],
        },
        {
          'id': 'risk-update.actions.legacy',
          'kind': 'listItem',
          'children': [
            {
              'id': 'risk-update.actions.legacy.body',
              'kind': 'paragraph',
              'children': [
                {
                  'id': 'risk-update.actions.legacy.body.text',
                  'kind': 'text',
                  'text': 'Keep the legacy banner enabled.',
                },
              ],
            },
          ],
        },
      ],
    },
  ],
};

final Map<String, Object?> _nativePatchEnvelope = {
  'id': 'risk-update',
  'schemaVersion': 1,
  'baseRevision': 'cms-rev-17',
  'revision': 'cms-rev-18',
  'operations': [
    {
      'op': 'replace',
      'nodeId': 'risk-update.summary',
      'block': {
        'id': 'risk-update.summary',
        'kind': 'paragraph',
        'children': [
          {
            'id': 'risk-update.summary.text',
            'kind': 'text',
            'text': 'Updated checks now apply before market and limit orders.',
          },
        ],
      },
    },
    {
      'op': 'insert-before',
      'siblingNodeId': 'risk-update.actions',
      'blocks': [
        {
          'id': 'risk-update.notice',
          'kind': 'paragraph',
          'children': [
            {
              'id': 'risk-update.notice.text',
              'kind': 'text',
              'text': 'This payload came from trusted app-controlled JSON.',
            },
          ],
        },
      ],
    },
    {
      'op': 'append-children',
      'parentNodeId': 'risk-update.actions',
      'blocks': [
        {
          'id': 'risk-update.actions.notify',
          'kind': 'listItem',
          'children': [
            {
              'id': 'risk-update.actions.notify.body',
              'kind': 'paragraph',
              'children': [
                {
                  'id': 'risk-update.actions.notify.body.text',
                  'kind': 'text',
                  'text': 'Notify support after the rollout flag is enabled.',
                },
              ],
            },
          ],
        },
      ],
    },
    {'op': 'remove', 'nodeId': 'risk-update.actions.legacy'},
  ],
};

class NativeJsonExample extends StatefulWidget {
  const NativeJsonExample({super.key});

  @override
  State<NativeJsonExample> createState() => _NativeJsonExampleState();
}

class _NativeJsonExampleState extends State<NativeJsonExample> {
  late TagflowDocument _document;
  late String _revision;
  bool _patched = false;

  @override
  void initState() {
    super.initState();
    _resetDocument();
  }

  void _resetDocument() {
    final nativeDocument = _codec.decodeDocument(_nativeJsonDocument);
    _document = _adapter.adapt(nativeDocument);
    _revision = nativeDocument.revision ?? 'unversioned';
    _patched = false;
  }

  void _applyPatchEnvelope() {
    final envelope = _codec.decodePatchEnvelope(_nativePatchEnvelope);
    final patches = _adapter.adaptPatches(envelope.operations);

    setState(() {
      _document = _document.applyPatches(patches);
      _revision = envelope.revision ?? _revision;
      _patched = true;
    });
  }

  void _reset() {
    setState(_resetDocument);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native JSON Transport')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Revision: $_revision',
            key: const ValueKey('native-json-revision'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Data-only JSON decoded with TagflowNativeBlockCodec and rendered '
            'through Tagflow.document(...).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(
                key: const ValueKey('native-json-apply-patch'),
                onPressed: _patched ? null : _applyPatchEnvelope,
                child: const Text('Apply patch envelope'),
              ),
              const SizedBox(width: 8),
              TextButton(
                key: const ValueKey('native-json-reset'),
                onPressed: _reset,
                child: const Text('Reset'),
              ),
            ],
          ),
          const Divider(height: 32),
          Tagflow.document(_document),
        ],
      ),
    );
  }
}
