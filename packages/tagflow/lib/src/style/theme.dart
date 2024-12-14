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
    final textTheme = theme.textTheme.apply(
      fontFamily: fontFamily,
    );

    return TagflowStyle(
      textStyle: textTheme.bodyMedium,
      // use css default margins for elements
      elementStyles: {
        'h1': ElementStyle(
          textStyle: textTheme.displayLarge,
          margin: const EdgeInsets.only(top: 16),
        ),
        'h2': ElementStyle(
          textStyle: textTheme.displayMedium,
          margin: const EdgeInsets.only(top: 16),
        ),
        'h3': ElementStyle(
          textStyle: textTheme.displaySmall,
          margin: const EdgeInsets.only(top: 16),
        ),
        'h4': ElementStyle(
          textStyle: textTheme.headlineMedium,
          margin: const EdgeInsets.only(top: 16),
        ),
        'h5': ElementStyle(
          textStyle: textTheme.headlineSmall,
          margin: const EdgeInsets.only(top: 16),
        ),
        'h6': ElementStyle(
          textStyle: textTheme.titleLarge,
          margin: const EdgeInsets.only(top: 16),
        ),
        'p': ElementStyle(
          textStyle: textTheme.bodyMedium,
          margin: const EdgeInsets.only(top: 16),
        ),
        'a': ElementStyle(
          textStyle: textTheme.bodyMedium?.apply(
            color: theme.colorScheme.secondary,
            decoration: TextDecoration.underline,
            decorationColor: theme.colorScheme.secondary,
          ),
        ),
        'code': ElementStyle(
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: textTheme.bodyMedium?.apply(
            fontFamily: codeFontFamily,
            fontFamilyFallback: fontFamily != null ? [fontFamily] : null,
          ),
        ),
        'pre': ElementStyle(
          padding: const EdgeInsets.all(16),
          textStyle: textTheme.bodyMedium?.apply(
            fontFamily: codeFontFamily,
            fontFamilyFallback: fontFamily != null ? [fontFamily] : null,
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
