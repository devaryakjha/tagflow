import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:tagflow/tagflow.dart';

class TestNode extends TagflowNode {
  TestNode({
    required super.tag,
    super.textContent,
    super.parent,
    LinkedHashMap<String, String>? attributes,
  }) : _attributes = attributes;

  @override
  List<TagflowNode> get children => _children;
  final List<TagflowNode> _children = [];

  @override
  set children(List<TagflowNode> value) {
    _children.clear();
    _children.addAll(value);
  }

  LinkedHashMap<String, String>? _attributes;

  @override
  LinkedHashMap<String, String>? get attributes => _attributes;

  @override
  String? operator [](String key) => _attributes?[key];

  @override
  void operator []=(String key, String value) {
    _attributes ??= LinkedHashMap<String, String>();
    _attributes![key] = value;
  }

  @override
  TestNode reparent([TagflowNode? newParent]) {
    return TestNode(
      tag: tag,
      textContent: textContent,
      parent: newParent,
      attributes: _attributes,
    );
  }
}

void main() {
  group('TagflowNodeStyle', () {
    test('style returns null when no style attribute', () {
      final node = TestNode(tag: 'div');
      expect(node.style, isNull);
    });

    test('style returns style attribute value', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'style': 'color: red;'}),
      );
      expect(node.style, 'color: red;');
    });

    test('styles parses style attribute correctly', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'style': 'color: red; font-size: 16px;'}),
      );
      expect(node.styles, {
        'color': 'red',
        'font-size': '16px',
      });
    });

    test('styles handles empty style attribute', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'style': ''}),
      );
      expect(node.styles, isNull);
    });

    test('classList returns empty list when no class attribute', () {
      final node = TestNode(tag: 'div');
      expect(node.classList, isEmpty);
    });

    test('classList parses class names correctly', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'class': 'one two three'}),
      );
      expect(node.classList, ['one', 'two', 'three']);
    });

    test('classList handles empty class attribute', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'class': ''}),
      );
      expect(node.classList, isEmpty);
    });

    test('className returns empty string when no class attribute', () {
      final node = TestNode(tag: 'div');
      expect(node.className, isNull);
    });

    test('className returns class attribute value', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'class': 'test-class'}),
      );
      expect(node.className, 'test-class');
    });

    test('className setter updates class attribute', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap<String, String>(),
      );
      node['class'] = 'new-class';
      expect(node.attributes?['class'], 'new-class');
    });

    test('classList setter updates class attribute', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap<String, String>(),
      );
      node.classList = ['one', 'two', 'three'];
      expect(node.attributes?['class'], 'one two three');
    });
  });

  group('TagflowNodeLink', () {
    test('isAnchor returns true for a tags', () {
      final node = TestNode(tag: 'a');
      expect(node.isAnchor, isTrue);
    });

    test('isAnchor returns false for non-a tags', () {
      final node = TestNode(tag: 'div');
      expect(node.isAnchor, isFalse);
    });

    test('href returns null when no href attribute', () {
      final node = TestNode(tag: 'a');
      expect(node.href, isNull);
    });

    test('href returns href attribute value', () {
      final node = TestNode(
        tag: 'a',
        attributes: LinkedHashMap.of({'href': 'https://example.com'}),
      );
      expect(node.href, 'https://example.com');
    });

    test('target returns null when no target attribute', () {
      final node = TestNode(tag: 'a');
      expect(node.target, isNull);
    });

    test('target returns target attribute value', () {
      final node = TestNode(
        tag: 'a',
        attributes: LinkedHashMap.of({'target': '_blank'}),
      );
      expect(node.target, '_blank');
    });

    test('parentHref returns null when no parent', () {
      final node = TestNode(tag: 'div');
      expect(node.parentHref, isNull);
    });

    test('parentHref returns parent href', () {
      final parent = TestNode(
        tag: 'a',
        attributes: LinkedHashMap.of({'href': 'https://example.com'}),
      );
      final child = TestNode(tag: 'div').reparent(parent);
      expect(child.parentHref, 'https://example.com');
    });
  });

  group('TagflowNodeSize', () {
    test('width returns null when no width attribute or style', () {
      final node = TestNode(tag: 'div');
      expect(node.width, isNull);
    });

    test('width returns parsed width attribute', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'width': '100px'}),
      );
      expect(node.width, 100);
    });

    test('width returns parsed width style', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'style': 'width: 100px;'}),
      );
      expect(node.width, 100);
    });

    test('height returns null when no height attribute or style', () {
      final node = TestNode(tag: 'div');
      expect(node.height, isNull);
    });

    test('height returns parsed height attribute', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'height': '100px'}),
      );
      expect(node.height, 100);
    });

    test('height returns parsed height style', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'style': 'height: 100px;'}),
      );
      expect(node.height, 100);
    });

    test('gap returns null when no gap style', () {
      final node = TestNode(tag: 'div');
      expect(node.gap, isNull);
    });

    test('gap returns parsed gap style', () {
      final node = TestNode(
        tag: 'div',
        attributes: LinkedHashMap.of({'style': 'gap: 10px;'}),
      );
      expect(node.gap, 10);
    });
  });
}
