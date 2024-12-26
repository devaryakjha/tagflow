import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html;
import 'package:tagflow/tagflow.dart';

void main() {
  group('ImgParser', () {
    const parser = ImgParser();

    test('canHandle correctly identifies img elements', () {
      final imgNode = html.parse('<img src="test.jpg">').body!.firstChild!;
      final divNode = html.parse('<div></div>').body!.firstChild!;

      expect(parser.canHandle(imgNode), true);
      expect(parser.canHandle(divNode), false);
    });

    test('parses img attributes correctly', () {
      final document = html.parse('''
        <img 
          src="test.jpg" 
          alt="Test Image"
          width="100"
          height="100"
          style="object-fit: cover"
        >
      ''');

      final imgNode = document.body!.firstChild!;
      final img = parser.tryParse(imgNode, const TagflowParser());

      expect(img, isNotNull);
      expect(img!['src'], 'test.jpg');
      expect(img['alt'], 'Test Image');
      expect(img['width'], '100');
      expect(img['height'], '100');
      expect(img.style, 'object-fit: cover');
    });

    test('handles missing attributes', () {
      final document = html.parse('<img>');
      final imgNode = document.body!.firstChild!;
      final img = parser.tryParse(imgNode, const TagflowParser());

      expect(img, isNotNull);
      expect(img!['src'], isEmpty);
      expect(img['alt'], isEmpty);
    });
  });
}
