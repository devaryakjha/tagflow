// ignore_for_file: lines_longer_than_80_chars

import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Base interface for element converters
abstract class ElementConverter<T extends TagflowNode> {
  /// Create a new element converter
  const ElementConverter();

  /// Supported tags for this converter
  /// Format:
  /// - "p" -> supports p tag
  /// - "blockquote footer" -> supports footer tag only inside blockquote
  /// - "ul > li" -> supports li tag only as direct child of ul
  /// - "!blockquote footer" -> supports footer tag except when inside blockquote
  /// - "!ul > li" -> supports li tag except when direct child of ul
  Set<String> get supportedTags;

  /// Whether this converter can handle the given element
  bool canHandle(TagflowNode element) {
    for (final selector in supportedTags) {
      if (_matchesSelector(element, selector)) {
        return true;
      }
    }
    return false;
  }

  /// Check if element matches a selector
  bool _matchesSelector(TagflowNode element, String selector) {
    // Handle negation
    if (selector.startsWith('!')) {
      log('Negation selector: $selector');
      final baseSelector = selector.substring(1);
      return element.tag == baseSelector.split(' ').last &&
          !matchPositiveSelector(element, baseSelector);
    }
    return matchPositiveSelector(element, selector);
  }

  @protected
  @visibleForTesting
  /// Match positive selectors (without negation)
  bool matchPositiveSelector(TagflowNode element, String selector) {
    // Handle pseudo-selectors
    if (selector.contains(':')) {
      final parts = selector.split(':');
      final baseSelector = parts[0];
      final pseudo = parts[1];

      // First check if base selector matches
      if (!matchPositiveSelector(element, baseSelector)) {
        return false;
      }

      // Then check pseudo selector
      return switch (pseudo) {
        'first-child' => element.isFirstChild,
        'last-child' => element.isLastChild,
        _ => false,
      };
    }

    // Simple tag match
    if (!selector.contains(' ')) {
      return selector == element.tag;
    }

    // Handle direct child selector (>)
    if (selector.contains('>')) {
      final parts = selector.split('>').map((e) => e.trim()).toList();
      var current = element;

      // Match from right to left
      for (var i = parts.length - 1; i >= 0; i--) {
        if (current.tag != parts[i]) return false;
        if (i > 0) {
          current = current.parent!;
        }
      }
      return true;
    }

    // Handle ancestor-descendant selector
    final parts = selector.split(' ').map((e) => e.trim()).toList();
    if (element.tag != parts.last) return false;

    // Check ancestors
    var parent = element.parent;
    for (var i = parts.length - 2; i >= 0; i--) {
      while (parent != null) {
        if (parent.tag == parts[i]) {
          if (i == 0) return true;
          break;
        }
        parent = parent.parent;
      }
      if (parent == null) return false;
      parent = parent.parent;
    }

    return false;
  }

  /// Convert the element to a widget
  Widget convert(T element, BuildContext context, TagflowConverter converter);

  /// Get the computed style for an element
  ///
  /// If [inherit] is false, it will not inherit from parent styles
  /// and will return an empty style if no style is found
  ///
  ///
  TagflowStyle resolveStyle(
    TagflowNode element,
    BuildContext context, {
    bool inherit = true,
  }) {
    return TagflowThemeProvider.of(
      context,
    ).resolveStyle(element, inherit: inherit, context: context);
  }

  @override
  String toString() => '$runtimeType(supportedTags: $supportedTags)';

  /// Lookup the first parent of the given tag
  TagflowNode? lookupParent(TagflowNode element, String tag) {
    var parent = element.parent;
    while (parent != null) {
      if (parent.tag == tag) return parent;
      parent = parent.parent;
    }
    return null;
  }
}

/// Main converter that orchestrates the conversion process
class TagflowConverter {
  /// Create a new converter with optional custom converters
  TagflowConverter([List<ElementConverter>? customConverters]) {
    if (customConverters != null) {
      _customConverters.addAll(customConverters);
    }
    _registerBuiltIns();
  }

  final List<ElementConverter> _customConverters = [];
  final List<ElementConverter> _builtInConverters = [];

  /// Add a custom converter
  void addConverter(ElementConverter converter) {
    _customConverters.add(converter);
  }

  /// Add multiple custom converters
  void addAllConverters(List<ElementConverter> converters) {
    _customConverters.addAll(converters);
  }

  void _registerBuiltIns() {
    _builtInConverters.addAll([
      const TextConverter(),
      const ImgConverter(),
      const CodeConverter(),
      const BlockquoteConverter(),
      const BlockquoteFooterConverter(),
      const HrConverter(),
      const ContainerConverter(),
      const ListConverter(),
      const ListItemConverter(),
      const TableConverter(),
      const TableCellConverter(),
    ]);
  }

  /// Convert a TagflowElement to a Widget
  Widget convert(TagflowNode element, BuildContext context) {
    // Try custom converters first
    for (final converter in _customConverters) {
      if (converter.canHandle(element)) {
        return converter.convert(element, context, this);
      }
    }

    // Then try built-in converters
    for (final converter in _builtInConverters) {
      if (converter.canHandle(element)) {
        return converter.convert(element, context, this);
      }
    }

    // Fallback to default converter
    return const DefaultConverter().convert(element, context, this);
  }

  /// Convert a list of elements to widgets
  List<Widget> convertChildren(
    List<TagflowNode> elements,
    BuildContext context,
  ) {
    return elements.map((e) => convert(e, context)).toList();
  }

  @override
  String toString() {
    return 'TagflowConverter(customConverters: $_customConverters, builtInConverters: $_builtInConverters)';
  }
}

/// Default fallback converter for unknown elements
class DefaultConverter extends ElementConverter {
  const DefaultConverter();

  @override
  Set<String> get supportedTags => const {};

  @override
  bool canHandle(TagflowNode element) => true;

  @override
  Widget convert(
    TagflowNode element,
    BuildContext context,
    TagflowConverter converter,
  ) {
    if (element.isTextNode) {
      final style = resolveStyle(element, context);

      return Text(
        element.textContent ?? '',
        style: style.textStyleWithColor,
        textAlign: style.textAlign,
      );
    }
    return const SizedBox.shrink();
  }
}
