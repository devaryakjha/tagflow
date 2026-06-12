import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

void main() {
  group('Tagflow.document widget updates', () {
    testWidgets('preserve keyed node state across document patches', (
      tester,
    ) async {
      final trackedStateIds = <int>[];
      final registry = TagflowComponentRegistry(
        overrides: {
          TagflowNodeKind.paragraph: (context, node) {
            if (node.id == 'tracked') {
              return _StatefulNodeProbe(
                nodeId: node.id,
                onBuild: trackedStateIds.add,
              );
            }

            return Wrap(children: context.renderChildren(node));
          },
        },
      );
      final document = TagflowDocument(
        id: 'doc',
        children: [
          TagflowDocumentNode.paragraph(
            id: 'tracked',
            children: [
              TagflowDocumentNode.text(id: 'tracked.text', text: 'Tracked'),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Tagflow.document(document, registry: registry),
        ),
      );

      final firstTrackedStateId = trackedStateIds.single;
      expect(find.text('tracked:$firstTrackedStateId'), findsOneWidget);

      final updated = document.applyPatch(
        TagflowDocumentPatch.insertBefore(
          siblingNodeId: 'tracked',
          nodes: [
            TagflowDocumentNode.paragraph(
              id: 'inserted',
              children: [
                TagflowDocumentNode.text(id: 'inserted.text', text: 'Inserted'),
              ],
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Tagflow.document(updated, registry: registry),
        ),
      );

      expect(find.text('Inserted'), findsOneWidget);
      expect(find.text('tracked:$firstTrackedStateId'), findsOneWidget);
      expect(trackedStateIds, [firstTrackedStateId, firstTrackedStateId]);
    });
  });
}

final class _StatefulNodeProbe extends StatefulWidget {
  const _StatefulNodeProbe({required this.nodeId, required this.onBuild});

  final String nodeId;
  final ValueChanged<int> onBuild;

  @override
  State<_StatefulNodeProbe> createState() => _StatefulNodeProbeState();
}

final class _StatefulNodeProbeState extends State<_StatefulNodeProbe> {
  static int _nextStateId = 0;

  late final int _stateId = ++_nextStateId;

  @override
  Widget build(BuildContext context) {
    widget.onBuild(_stateId);
    return Text('${widget.nodeId}:$_stateId');
  }
}
