import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:tagflow/tagflow.dart';

class TagflowImgElement extends TagflowNode {
  const TagflowImgElement({
    super.tag = 'img',
    Map<String, String>? attributes,
  }) : _attributes = attributes ?? const {};

  /// Element's attributes
  final Map<String, String> _attributes;

  @override
  LinkedHashMap<String, String>? get attributes =>
      LinkedHashMap.from(_attributes);

  /// Returns the src attribute for media elements
  String? get src => this['src'];

  /// Returns the alt text for media elements
  String? get alt => this['alt'];

  /// Returns the object-fit style as BoxFit
  BoxFit? get fit => styles?['object-fit'] != null
      ? StyleParser.parseBoxFit(styles!['object-fit']!)
      : null;

  @override
  void operator []=(String key, String value) {
    _attributes[key] = value;
  }

  @override
  String operator [](String key) {
    return _attributes[key] ?? '';
  }

  @override
  TagflowNode reparent([TagflowNode? newParent]) {
    return TagflowImgElement(
      tag: tag,
      attributes: attributes,
    );
  }

  @override
  List<Object?> get props => [tag, attributes, src, alt, fit];
}
