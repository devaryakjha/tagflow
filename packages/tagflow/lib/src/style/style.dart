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
    this.headingStyles = const {},
    this.paragraphStyle,
    this.linkStyle,
  });

  /// Text styling
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

  /// Styles for headings
  final Map<String, TextStyle> headingStyles;

  /// Style for paragraphs
  final TextStyle? paragraphStyle;

  /// Style for links
  final TextStyle? linkStyle;

  /// Create a copy of this style with specific overrides
  TagflowStyle copyWith({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    BoxDecoration? decoration,
    Alignment? alignment,
    Map<String, TextStyle>? headingStyles,
    TextStyle? paragraphStyle,
    TextStyle? linkStyle,
  }) {
    return TagflowStyle(
      textStyle: textStyle ?? this.textStyle,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
      alignment: alignment ?? this.alignment,
      headingStyles: headingStyles ?? this.headingStyles,
      paragraphStyle: paragraphStyle ?? this.paragraphStyle,
      linkStyle: linkStyle ?? this.linkStyle,
    );
  }

  /// Merge two styles, with other taking precedence
  TagflowStyle merge(TagflowStyle? other) {
    if (other == null) return this;

    return TagflowStyle(
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      decoration: other.decoration ?? decoration,
      alignment: other.alignment ?? alignment,
      headingStyles: {
        ...headingStyles,
        ...other.headingStyles,
      },
      paragraphStyle:
          other.paragraphStyle?.merge(paragraphStyle) ?? paragraphStyle,
      linkStyle: other.linkStyle?.merge(linkStyle) ?? linkStyle,
    );
  }
}

/// Theme that provides default styles for all elements
class TagflowTheme {
  /// Create a new theme
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
        headingStyles: {
          'h1': TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          'h2': TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          'h3': TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        },
        paragraphStyle: TextStyle(
          height: 1.5,
        ),
        linkStyle: TextStyle(
          color: Color(0xFF2563EB),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  /// Create a dark theme
  factory TagflowTheme.dark() {
    return const TagflowTheme(
      baseStyle: TagflowStyle(
        textStyle: TextStyle(
          fontSize: 16,
          color: Color(0xFFFFFFFF),
        ),
        // Add dark theme specific styles
      ),
    );
  }

  /// Base style for all elements
  final TagflowStyle baseStyle;

  /// Styles for specific tags
  final Map<String, TagflowStyle> tagStyles;

  /// Styles for specific classes
  final Map<String, TagflowStyle> classStyles;

  /// Get style for a specific tag
  TagflowStyle? getTagStyle(String tag) => tagStyles[tag.toLowerCase()];

  /// Get style for a specific class
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
