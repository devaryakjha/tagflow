import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// Theme that provides default styles for all elements
class TagflowTheme {
  /// Create a new theme with the given base style
  const TagflowTheme({
    required this.baseStyle,
    this.classStyles = const {},
  });

  /// Create a theme from a Flutter theme
  ///
  /// `fontFamily` and `codeFontFamily` are used to set the font family for the
  /// text and code elements.
  ///
  /// Here is how to text styles are picked up from the theme:
  ///
  /// - `bodyMedium` is used for `p` elements
  /// - `displayLarge` is used for `h1` elements
  /// - `displayMedium` is used for `h2` elements
  /// - `displaySmall` is used for `h3` elements
  /// - `headlineMedium` is used for `h4` elements
  /// - `headlineSmall` is used for `h5` elements
  /// - `titleLarge` is used for `h6` elements
  factory TagflowTheme.fromTheme(
    ThemeData theme, {
    String? fontFamily,
    String? codeFontFamily,
  }) = _TagflowFromTheme;

  /// Base style for all elements (e.g., text, headings, etc.)
  final TagflowStyle baseStyle;

  /// Styles for specific classes (e.g., '.my-class')
  final Map<String, TagflowStyle> classStyles;

  /// Get style for a specific class (e.g., '.my-class')
  TagflowStyle? getClassStyle(String className) => classStyles[className];
}

class _TagflowFromTheme extends TagflowTheme {
  _TagflowFromTheme(
    this.theme, {
    String? fontFamily,
    String? codeFontFamily,
  }) : super(
          baseStyle: _createBaseStyle(theme, fontFamily, codeFontFamily),
          classStyles: _createClassStyles(theme.textTheme),
        );

  final ThemeData theme;

  static TagflowStyle _createBaseStyle(
    ThemeData theme,
    String? fontFamily,
    String? codeFontFamily,
  ) {
    final textTheme = theme.textTheme.apply(fontFamily: fontFamily);
    final rem = textTheme.bodyMedium?.fontSize ?? 14.0;

    return TagflowStyle(
      textStyle: textTheme.bodyMedium,
      elementStyles: {
        'h1': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem * 0.67),
          textStyle: textTheme.displayLarge?.copyWith(
            fontSize: rem * 2,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        'h2': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem * 0.83),
          textStyle: textTheme.displayMedium?.copyWith(
            fontSize: rem * 1.5,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        'h3': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem),
          textStyle: textTheme.displaySmall?.copyWith(
            fontSize: rem * 1.17,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        'h4': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem),
          textStyle: textTheme.headlineMedium?.copyWith(
            fontSize: rem,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        'h5': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem),
          textStyle: textTheme.headlineSmall?.copyWith(
            fontSize: rem * 0.83,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        'h6': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem),
          textStyle: textTheme.titleLarge?.copyWith(
            fontSize: rem * 0.67,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        'p': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem),
        ),
        'span': const ElementStyle(),
        'a': const ElementStyle(
          textStyle: TextStyle(
            color: Color(0xFF0000EE),
            decoration: TextDecoration.underline,
            decorationColor: Color(0xFF0000EE),
          ),
        ),
        'code': ElementStyle(
          textStyle: TextStyle(
            fontFamily: codeFontFamily ?? 'monospace',
            height: 1.2,
          ),
        ),
        'pre': ElementStyle(
          margin: EdgeInsets.symmetric(vertical: rem),
          textStyle: TextStyle(
            fontFamily: codeFontFamily ?? 'monospace',
            height: 1.5,
          ),
        ),
        'blockquote': ElementStyle(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey.withValues(alpha: 0.5),
                width: 5,
              ),
            ),
          ),
        ),
        'img': ElementStyle(
          // Preserves aspect ratio by default
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
        ),

        // styles
        'b': const ElementStyle(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        'strong': const ElementStyle(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        'i': const ElementStyle(
          textStyle: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        'em': const ElementStyle(
          textStyle: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        'u': const ElementStyle(
          textStyle: TextStyle(
            decoration: TextDecoration.underline,
          ),
        ),
        's': const ElementStyle(
          textStyle: TextStyle(
            decoration: TextDecoration.lineThrough,
          ),
        ),
      },
    );
  }

  static Map<String, TagflowStyle> _createClassStyles(TextTheme textTheme) {
    return {};
  }
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
    return provider?.theme ?? TagflowTheme.fromTheme(Theme.of(context));
  }

  @override
  bool updateShouldNotify(TagflowThemeProvider oldWidget) {
    return theme != oldWidget.theme;
  }
}
