// lib/src/style/style.dart
import 'package:flutter/widgets.dart';

/// Represents a set of styles for an element
class TagflowStyle {
  /// Create a new style
  const TagflowStyle({
    this.textStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.alignment,
    this.elementStyles = const {},
    this.defaultElementStyle,
  });

  /// Base text style
  final TextStyle? textStyle;

  /// Padding
  final EdgeInsets? padding;

  /// Margin
  final EdgeInsets? margin;

  /// Background color
  final Color? backgroundColor;

  /// Decoration
  final BoxDecoration? decoration;

  /// Alignment
  final Alignment? alignment;

  /// Style applied to all elements (like CSS *)
  final ElementStyle? defaultElementStyle;

  /// Styles for specific HTML elements
  /// Keys are HTML element names (e.g., 'p', 'h1', 'strong', 'em')
  final Map<String, ElementStyle> elementStyles;

  /// Create a copy of this style with specific overrides
  TagflowStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    BoxDecoration? decoration,
    Alignment? alignment,
    Map<String, ElementStyle>? elementStyles,
    ElementStyle? defaultElementStyle,
  }) {
    return TagflowStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      elementStyles: elementStyles ?? this.elementStyles,
      defaultElementStyle: defaultElementStyle ?? this.defaultElementStyle,
    );
  }

  /// Merge two styles, with other taking precedence
  TagflowStyle merge(TagflowStyle? other) {
    if (other == null) return this;

    return TagflowStyle(
      textStyle:
          textStyle?.merge(other.textStyle) ?? other.textStyle ?? textStyle,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      decoration: other.decoration ?? decoration,
      alignment: other.alignment ?? alignment,
      elementStyles: {
        ...elementStyles,
        for (final entry in other.elementStyles.entries)
          entry.key:
              elementStyles[entry.key]?.merge(entry.value) ?? entry.value,
      },
      defaultElementStyle:
          other.defaultElementStyle?.merge(defaultElementStyle) ??
              defaultElementStyle,
    );
  }

  /// Get style for a specific HTML element
  ElementStyle? getElementStyle(String tag) {
    // Start with default style if exists
    final baseStyle = defaultElementStyle;

    // Get tag-specific style
    final tagStyle = elementStyles[tag.toLowerCase()];

    // If we have both, merge them, otherwise return whichever exists
    if (baseStyle != null && tagStyle != null) {
      return baseStyle.merge(tagStyle);
    }

    return tagStyle ?? baseStyle;
  }
}

/// Style configuration for a specific HTML element
class ElementStyle {
  /// Create a new element style
  const ElementStyle({
    this.textStyle,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
  });

  /// Text style
  final TextStyle? textStyle;

  /// element's padding
  final EdgeInsets? padding;

  /// element's margin
  final EdgeInsets? margin;

  /// element's decoration
  final BoxDecoration? decoration;

  /// element's alignment
  final Alignment? alignment;

  /// Merge two element styles
  ElementStyle merge(ElementStyle? other) {
    if (other == null) return this;
    return ElementStyle(
      textStyle:
          textStyle?.merge(other.textStyle) ?? other.textStyle ?? textStyle,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      decoration: other.decoration ?? decoration,
      alignment: other.alignment ?? alignment,
    );
  }
}

/// Theme that provides default styles for all elements
class TagflowTheme {
  /// Create a new theme with the given base style
  const TagflowTheme({
    required this.baseStyle,
    this.tagStyles = const {},
    this.classStyles = const {},
  });

  /// Create a light theme
  factory TagflowTheme.light() {
    return const TagflowTheme(
      baseStyle: TagflowStyle(
        textStyle: TextStyle(
          fontSize: 16,
          color: Color(0xFF000000),
        ),
        elementStyles: {
          // Headings
          'h1': ElementStyle(
            textStyle: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            margin: EdgeInsets.symmetric(vertical: 16),
          ),
          'h2': ElementStyle(
            textStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            margin: EdgeInsets.symmetric(vertical: 12),
          ),
          'h3': ElementStyle(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          'h4': ElementStyle(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          'h5': ElementStyle(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          'h6': ElementStyle(
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          // Text elements
          'p': ElementStyle(
            textStyle: TextStyle(height: 1.5),
            margin: EdgeInsets.symmetric(vertical: 8),
          ),
          'a': ElementStyle(
            textStyle: TextStyle(
              color: Color(0xFF2563EB),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF2563EB),
            ),
          ),
          // Emphasis
          'em': ElementStyle(
            textStyle: TextStyle(fontStyle: FontStyle.italic),
          ),
          'i': ElementStyle(
            textStyle: TextStyle(fontStyle: FontStyle.italic),
          ),
          'strong': ElementStyle(
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          'b': ElementStyle(
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
          // Other inline elements
          'span': ElementStyle(
            textStyle: TextStyle(),
          ),
          'code': ElementStyle(
            textStyle: TextStyle(
              fontFamily: 'monospace',
              backgroundColor: Color(0xFFF1F1F1),
            ),
            padding: EdgeInsets.symmetric(horizontal: 4),
          ),
        },
      ),
    );
  }

  /// Create a dark theme
  factory TagflowTheme.dark() {
    final light = TagflowTheme.light();

    return TagflowTheme(
      baseStyle: TagflowStyle(
        textStyle: const TextStyle(
          fontSize: 16,
          color: Color(0xFFFFFFFF),
        ),
        elementStyles: light.baseStyle.elementStyles,
      ),
    );
  }

  /// Base style for all elements (e.g., text, headings, etc.)
  final TagflowStyle baseStyle;

  /// Styles for specific HTML elements
  final Map<String, TagflowStyle> tagStyles;

  /// Styles for specific classes (e.g., '.my-class')
  final Map<String, TagflowStyle> classStyles;

  /// Get style for a specific HTML element
  TagflowStyle? getTagStyle(String tag) => tagStyles[tag.toLowerCase()];

  /// Get style for a specific class (e.g., '.my-class')
  TagflowStyle? getClassStyle(String className) => classStyles[className];
}

/// Provider for accessing current theme
class TagflowThemeProvider extends InheritedWidget {
  /// Create a new theme provider
  const TagflowThemeProvider({
    required this.theme,
    required super.child,
    super.key,
  });

  /// Theme to provide
  final TagflowTheme theme;

  /// Returns the current theme
  static TagflowTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<TagflowThemeProvider>();
    return provider?.theme ?? TagflowTheme.light();
  }

  @override
  bool updateShouldNotify(TagflowThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
