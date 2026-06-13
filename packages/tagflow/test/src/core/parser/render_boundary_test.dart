import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/legacy.dart';

void main() {
  group('TagflowRenderBoundary', () {
    test('stops parsing top-level siblings at a matching comment', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(end: 'end-of-mobile'),
      );

      final node = parser.parse('''
<p>Visible</p>
<!--end-of-mobile-->
<p>Hidden</p>
''');

      expect(node.tag, 'p');
      expect(node.children.single.textContent, 'Visible');
    });

    test('stops parsing nested siblings at a matching comment', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(end: 'end-of-mobile'),
      );

      final node = parser.parse('''
<section>
  <p>Visible</p>
  <!-- end-of-mobile -->
  <p>Hidden</p>
</section>
''');

      expect(node.tag, 'section');
      expect(node.children, hasLength(1));
      expect(node.children.single.tag, 'p');
      expect(node.children.single.children.single.textContent, 'Visible');
    });

    test('returns complete content when no boundary matches', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(end: 'end-of-mobile'),
      );

      final node = parser.parse(
        '<p>Visible</p><!--other--><p>Still visible</p>',
      );

      expect(node.tag, 'div');
      expect(node.children, hasLength(2));
      expect(node.children.first.children.single.textContent, 'Visible');
      expect(node.children.last.children.single.textContent, 'Still visible');
    });

    test('does not treat brackets as optional comment syntax', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(end: 'end-of-mobile'),
      );

      final node = parser.parse(
        '<p>Visible</p><!--[end-of-mobile]--><p>Still visible</p>',
      );

      expect(node.tag, 'div');
      expect(node.children, hasLength(2));
      expect(node.children.first.children.single.textContent, 'Visible');
      expect(node.children.last.children.single.textContent, 'Still visible');
    });

    test(
      'matches bracketed comments when brackets are configured explicitly',
      () {
        const parser = TagflowParser(
          renderBoundary: TagflowRenderBoundary.comment(end: '[end-of-mobile]'),
        );

        final node = parser.parse(
          '<p>Visible</p><!--[end-of-mobile]--><p>Hidden</p>',
        );

        expect(node.tag, 'p');
        expect(node.children.single.textContent, 'Visible');
      },
    );

    test('starts parsing after a matching start comment', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(start: 'start-of-mobile'),
      );

      final node = parser.parse('''
<p>Hidden</p>
<!--start-of-mobile-->
<p>Visible</p>
''');

      expect(node.tag, 'p');
      expect(node.children.single.textContent, 'Visible');
    });

    test('parses only content between matching comments', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(
          start: 'start-of-mobile',
          end: 'end-of-mobile',
        ),
      );

      final node = parser.parse('''
<p>Hidden before</p>
<!--start-of-mobile-->
<p>Visible</p>
<!--end-of-mobile-->
<p>Hidden after</p>
''');

      expect(node.tag, 'p');
      expect(node.children.single.textContent, 'Visible');
    });

    test('starts from the beginning when start marker is absent', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(start: 'start-of-mobile'),
      );

      final node = parser.parse('<p>Visible</p>');

      expect(node.tag, 'p');
      expect(node.children.single.textContent, 'Visible');
    });

    test(
      'starts from the beginning when start marker is absent but end exists',
      () {
        const parser = TagflowParser(
          renderBoundary: TagflowRenderBoundary.comment(
            start: 'start-of-mobile',
            end: 'end-of-mobile',
          ),
        );

        final node = parser.parse('''
<p>Visible</p>
<!--end-of-mobile-->
<p>Hidden after</p>
''');

        expect(node.tag, 'p');
        expect(node.children.single.textContent, 'Visible');
      },
    );

    test('continues to the end when end marker is absent', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(
          start: 'start-of-mobile',
          end: 'end-of-mobile',
        ),
      );

      final node = parser.parse('''
<p>Hidden before</p>
<!--start-of-mobile-->
<p>Visible</p>
<p>Still visible</p>
''');

      expect(node.tag, 'div');
      expect(node.children, hasLength(2));
      expect(node.children.first.children.single.textContent, 'Visible');
      expect(node.children.last.children.single.textContent, 'Still visible');
    });

    test('shares boundary state across nested nodes and later siblings', () {
      const parser = TagflowParser(
        renderBoundary: TagflowRenderBoundary.comment(
          start: 'start-of-mobile',
          end: 'end-of-mobile',
        ),
      );

      final node = parser.parse('''
<section>
  <p>Hidden</p>
  <!-- start-of-mobile -->
  <p>Visible in section</p>
</section>
<p>Visible sibling</p>
<!--end-of-mobile-->
<p>Hidden after</p>
''');

      expect(node.tag, 'div');
      expect(node.children, hasLength(2));
      expect(node.children.first.tag, 'section');
      expect(
        node.children.first.children.single.children.single.textContent,
        'Visible in section',
      );
      expect(node.children.last.children.single.textContent, 'Visible sibling');
    });
  });
}
