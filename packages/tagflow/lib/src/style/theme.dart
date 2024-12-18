import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// A theme that provides default styles for all HTML elements in Tagflow.
///
/// The theme system follows a cascading model similar to CSS, where styles are
/// applied in the following order of precedence (from lowest to highest):
///
/// 1. Base style (applies to all elements)
/// 2. Universal selector (*) styles
/// 3. Element-specific styles (e.g., styles for 'p', 'h1', etc.)
/// 4. Class styles (styles applied via class attributes)
/// 5. Inline styles (styles defined in the style attribute)
///
/// Example usage:
/// ```dart
/// TagflowTheme.fromTheme(
///   Theme.of(context),
///   classStyles: {
///     'highlight': TagflowStyle(
///       elementStyles: {
///         '*': ElementStyle(  // Applies to all elements with class 'highlight'
///           decoration: BoxDecoration(
///             color: Colors.yellow,
///           ),
///         ),
///         'p': ElementStyle(  // Only applies to <p> with class 'highlight'
///           padding: EdgeInsets.all(8),
///         ),
///       },
///     ),
///   },
/// )
/// ```
class TagflowTheme extends Equatable {
  /// Create a new [TagflowTheme]
  const TagflowTheme({
    required this.styles,
  });

  /// Create a new theme from a Flutter theme
  factory TagflowTheme.fromTheme(ThemeData theme) {
    final textTheme = theme.textTheme;
    final rem = textTheme.bodyMedium?.fontSize ?? 14.0;

    return TagflowTheme(
      styles: {
        '*': TagflowStyle(
          textStyle: textTheme.bodyMedium,
          padding: EdgeInsets.all(rem * 0.5),
        ),
        'h1': TagflowStyle(
          textStyle: textTheme.displayLarge?.copyWith(
            fontSize: rem * 2,
            fontWeight: FontWeight.w800,
          ),
          margin: EdgeInsets.symmetric(vertical: rem),
        ),
        // ... other default styles
      },
    );
  }

  /// Map of selectors to styles
  /// Keys can be:
  /// - Tag names (e.g., 'p', 'h1')
  /// - Universal selector ('*')
  /// - Class selectors (e.g., '.highlight')
  final Map<String, TagflowStyle> styles;

  /// Get style for an element, merging all applicable styles
  TagflowStyle resolveStyle(TagflowElement element) {
    // Start with universal style if exists
    var result = styles['*'] ?? const TagflowStyle();

    // Add tag style
    if (styles.containsKey(element.tag)) {
      result = result.merge(styles[element.tag]);
    }

    // Add class styles
    final classes = element.attributes['class']?.split(' ') ?? [];
    for (final className in classes) {
      final classStyle = styles['.${className.trim()}'];
      if (classStyle != null) {
        result = result.merge(classStyle);
      }
    }

    // Add inline styles last using StyleParser
    final inlineStyle =
        StyleParser.parseInlineStyle(element.attributes['style']);
    if (inlineStyle != null) {
      result = result.merge(inlineStyle);
    }

    return result;
  }

  @override
  List<Object?> get props => [styles];
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
