import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('accessibility', () {
    testWidgets('should expose headings as headers with their level', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const Tagflow.html(html: '<h2>Overview</h2>')),
      );

      expect(
        tester.getSemantics(find.text('Overview')),
        matchesSemantics(label: 'Overview', isHeader: true),
      );
      expect(
        tester.getSemantics(find.text('Overview')).getSemanticsData(),
        isA<SemanticsData>().having((d) => d.headingLevel, 'headingLevel', 2),
      );
      semantics.dispose();
    });

    testWidgets('should expose links and activate them from the keyboard', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final tapped = <String>[];
      await tester.pumpWidget(
        _app(
          Tagflow.document(
            TagflowDocument(
              id: 'doc',
              children: [
                TagflowDocumentNode.link(
                  id: 'link',
                  url: Uri.parse('https://example.com'),
                  children: [
                    TagflowDocumentNode.text(id: 'link.text', text: 'Docs'),
                  ],
                ),
              ],
            ),
            viewOptions: TagflowViewOptions(
              linkTapCallback: (url, _) => tapped.add(url),
            ),
          ),
        ),
      );

      // The link flows inline as a text span with its own link node.
      expect(find.semantics.byFlag(SemanticsFlag.isLink), findsOne);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(tapped, ['https://example.com']);
      semantics.dispose();
    });

    testWidgets('should tab through inline links in reading order', (
      tester,
    ) async {
      final tapped = <String>[];
      await tester.pumpWidget(
        _app(
          Tagflow.html(
            html:
                '<p>Read <a href="https://a.example/">one</a> and '
                '<a href="https://b.example/">two</a>.</p>',
            viewOptions: TagflowViewOptions(
              linkTapCallback: (url, _) => tapped.add(url),
            ),
          ),
        ),
      );

      for (var i = 0; i < 2; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      }
      await tester.pump();

      expect(tapped, ['https://a.example/', 'https://b.example/']);
      // Taps on the text still reach the links.
      expect(find.text('Read one and two.', findRichText: true), findsOne);
    });

    testWidgets('should show a focus ring on a focused link', (tester) async {
      await tester.pumpWidget(
        _app(
          Tagflow.html(
            html: '<p>See <a href="https://example.com">Docs</a></p>',
            viewOptions: TagflowViewOptions(linkTapCallback: (_, _) {}),
          ),
        ),
      );

      // The link text gets a background while its focus target is focused.
      bool linkHighlighted() {
        final rich = tester.widget<RichText>(
          find.textContaining('Docs', findRichText: true),
        );
        return rich.text.toStringDeep().contains('backgroundColor');
      }

      expect(linkHighlighted(), isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(linkHighlighted(), isTrue);
    });

    testWidgets('should label images with their alt text', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          Tagflow.html(
            html:
                '<img src="https://example.com/a.png" alt="A chart"> '
                '<img src="https://example.com/b.png" alt="">',
            viewOptions: TagflowViewOptions(
              imageErrorBuilder: (_, _, _) => const SizedBox(width: 10),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('A chart'), findsOneWidget);
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images.first.excludeFromSemantics, isFalse);
      expect(images.last.excludeFromSemantics, isTrue);
      semantics.dispose();
    });

    testWidgets('should expose the disclosure toggle state', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const Tagflow.html(
            html:
                '<details><summary>More</summary><p>Hidden body</p></details>',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('More')),
        matchesSemantics(
          label: 'More',
          isButton: true,
          isFocusable: true,
          hasExpandedState: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      // The chevron is drawn and excluded, so no stray text is read.
      expect(find.text('>'), findsNothing);

      await tester.tap(find.text('More'));
      await tester.pump();

      expect(
        tester.getSemantics(find.text('More')),
        matchesSemantics(
          label: 'More',
          isButton: true,
          isFocusable: true,
          hasExpandedState: true,
          isExpanded: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      semantics.dispose();
    });

    testWidgets('should toggle a disclosure from the keyboard', (tester) async {
      await tester.pumpWidget(
        _app(
          const Tagflow.html(
            html: '<details><summary>More</summary><p>Body</p></details>',
          ),
        ),
      );
      expect(find.text('Body'), findsNothing);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('should mark table header cells', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          const Tagflow.html(
            html: '<table><tr><th>Name</th></tr><tr><td>Ada</td></tr></table>',
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Name')),
        matchesSemantics(label: 'Name', hint: 'Column header'),
      );
      expect(
        tester.getSemantics(find.text('Ada')),
        matchesSemantics(label: 'Ada'),
      );
      semantics.dispose();
    });
  });
}
