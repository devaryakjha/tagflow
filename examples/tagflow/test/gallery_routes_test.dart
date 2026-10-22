import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow_example/screens/content_policy_example.dart';
import 'package:tagflow_example/screens/document_patch_example.dart';
import 'package:tagflow_example/screens/markdown_example.dart';
import 'package:tagflow_example/screens/streaming_example.dart';

Future<void> _pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(home: screen));
  await tester.pump();
}

void main() {
  testWidgets('should render Markdown and toggle its source', (tester) async {
    await _pump(tester, const MarkdownExample());

    expect(find.text('Release notes'), findsOneWidget);
    expect(find.textContaining('alert('), findsNothing);

    await tester.tap(find.byKey(const ValueKey('markdown-show-source')));
    await tester.pump();

    expect(find.textContaining('# Release notes'), findsOneWidget);
  });

  testWidgets('should stream the simulated answer to completion', (
    tester,
  ) async {
    await _pump(tester, const StreamingExample());

    final status = find.byKey(const ValueKey('streaming-status'));
    expect(tester.widget<Text>(status).data, startsWith('Streaming: '));

    await tester.pump(const Duration(seconds: 30));
    await tester.pump();

    expect(tester.widget<Text>(status).data, startsWith('Done: '));
    expect(find.text('Why patches beat re-rendering'), findsOneWidget);
  });

  testWidgets('should finish the stream at once when asked', (tester) async {
    await _pump(tester, const StreamingExample());
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const ValueKey('streaming-finish')));
    await tester.pump();

    final status = find.byKey(const ValueKey('streaming-status'));
    expect(tester.widget<Text>(status).data, startsWith('Done: '));
    expect(find.textContaining('Nothing leaves the device.'), findsOneWidget);
  });

  testWidgets('should keep a ticked task after patches elsewhere', (
    tester,
  ) async {
    await _pump(tester, const DocumentPatchExample());

    final firstTask = find.descendant(
      of: find.byKey(const ValueKey('task-card-task-1')),
      matching: find.byType(Checkbox),
    );
    await tester.tap(firstTask);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('patch-append')));
    await tester.tap(find.byKey(const ValueKey('patch-insert')));
    await tester.tap(find.byKey(const ValueKey('patch-replace')));
    await tester.tap(find.byKey(const ValueKey('patch-remove')));
    await tester.pump();

    expect(tester.widget<Checkbox>(firstTask).value, isTrue);
    expect(find.text('Revision 2'), findsOneWidget);
    expect(find.text('Urgent task task-5'), findsOneWidget);
    expect(find.text('Follow-up task task-4'), findsNothing);

    await tester.scrollUntilVisible(find.text('removeNode(task-4)'), 200);
    expect(find.text('removeNode(task-4)'), findsOneWidget);
  });

  testWidgets('should show placeholders for blocked content on request', (
    tester,
  ) async {
    await _pump(tester, const ContentPolicyExample());

    expect(
      find.text('This paragraph is safe and always renders.'),
      findsOneWidget,
    );
    expect(find.text('Unsupported content'), findsNothing);

    await tester.tap(find.text('Placeholder'));
    await tester.pumpAndSettle();

    expect(find.text('Unsupported content'), findsWidgets);
  });
}
