import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// A theme that provides default styles for all HTML elements in Tagflow.
class TagflowTheme extends Equatable {
  /// Create a new [TagflowTheme]
  const TagflowTheme._({
    this.styles = const {},
    this.namedColors = const {},
    this.defaultStyle = const TagflowStyle(),
  });

  /// Create a new [TagflowTheme] with raw style definitions.
  ///
  /// This constructor allows complete control over styles without any defaults.
  /// Useful for creating specialized themes or when you need full
  /// control over styling.
  ///
  /// Example:
  /// ```dart
  /// final theme = TagflowTheme.raw(
  ///   styles: {
  ///     'p': TagflowStyle(margin: EdgeInsets.all(8)),
  ///     '.primary': TagflowStyle(textStyle: TextStyle(color: Colors.blue)),
  ///   },
  ///   namedColors: {
  ///     'brand': Color(0xFF123456),
  ///   },
  ///   defaultStyle: TagflowStyle(
  ///     textStyle: TextStyle(fontSize: 16),
  ///   ),
  /// );
  ///
  /// See also:
  /// - [TagflowTheme.fromTheme] for creating a theme from a Flutter theme.
  /// - [TagflowTheme.article] for creating a theme optimized for article/blog content.
  /// ```
  const TagflowTheme.raw({
    required this.styles,
    required this.defaultStyle,
    this.namedColors = const {},
  });

  /// Create a new theme from a Flutter theme with customization options
  factory TagflowTheme.fromTheme(
    ThemeData theme, {
    Map<String, TagflowStyle>? additionalStyles,
    Map<String, Color>? additionalColors,
    double baseFontSize = 16.0,
    bool useSystemColors = true,
    // Text styles
    TextStyle? h1Style,
    TextStyle? h2Style,
    TextStyle? h3Style,
    TextStyle? h4Style,
    TextStyle? h5Style,
    TextStyle? h6Style,
    TextStyle? codeStyle,
    TextStyle? preStyle,
    TextStyle? strongStyle,
    TextStyle? emStyle,
    // Spacing overrides
    EdgeInsets? defaultPadding,
    EdgeInsets? blockPadding,
    EdgeInsets? blockMargin,
    EdgeInsets? paragraphMargin,
    EdgeInsets? listPadding,
    EdgeInsets? tableCellPadding,
    EdgeInsets? inlineCodePadding,
    double? borderWidth,
  }) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Default spacing values
    final defaultSpacing = EdgeInsets.all(baseFontSize * 0.5);
    final defaultBlockPadding = EdgeInsets.all(baseFontSize);
    final defaultBlockMargin = EdgeInsets.symmetric(vertical: baseFontSize);
    final defaultListPadding = EdgeInsets.only(left: baseFontSize * 1.5);
    final defaultTableCellPadding = EdgeInsets.all(baseFontSize * 0.5);
    final defaultInlineCodePadding = EdgeInsets.symmetric(
      horizontal: baseFontSize * 0.25,
      vertical: baseFontSize * 0.125,
    );
    final defaultBorderWidth = baseFontSize * 0.25;

    return TagflowTheme._(
      defaultStyle: TagflowStyle(
        textStyle: textTheme.bodyMedium,
        padding: defaultPadding ?? defaultSpacing,
      ),
      styles: {
        'p': TagflowStyle(
          margin: paragraphMargin ?? defaultBlockMargin,
        ),
        'h1': TagflowStyle(
          textStyle: h1Style ?? textTheme.displayLarge,
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.8),
        ),
        'h2': TagflowStyle(
          textStyle: h2Style ?? textTheme.displayMedium,
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.7),
        ),
        'h3': TagflowStyle(
          textStyle: h3Style ?? textTheme.displaySmall,
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.6),
        ),
        'h4': TagflowStyle(
          textStyle: h4Style ?? textTheme.headlineMedium,
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.5),
        ),
        'h5': TagflowStyle(
          textStyle: h5Style ?? textTheme.headlineSmall,
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.4),
        ),
        'h6': TagflowStyle(
          textStyle: h6Style ?? textTheme.titleLarge,
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.3),
        ),
        'pre': TagflowStyle(
          textStyle: preStyle ??
              textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
          padding: blockPadding ?? defaultBlockPadding,
          margin: blockMargin ?? defaultBlockMargin,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        ),
        'blockquote': TagflowStyle(
          padding: blockPadding ?? defaultBlockPadding,
          margin: blockMargin ?? defaultBlockMargin,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          borderLeft: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: borderWidth ?? defaultBorderWidth,
          ),
        ),

        // Lists
        'ul': TagflowStyle(
          padding: listPadding ?? defaultListPadding,
          margin: blockMargin ?? defaultBlockMargin,
        ),
        'ol': TagflowStyle(
          padding: listPadding ?? defaultListPadding,
          margin: blockMargin ?? defaultBlockMargin,
        ),

        // Tables
        'table': TagflowStyle(
          margin: blockMargin ?? defaultBlockMargin,
          border: Border.all(
            color: colorScheme.outline,
            width: borderWidth ?? defaultBorderWidth,
          ),
        ),
        'th': TagflowStyle(
          padding: tableCellPadding ?? defaultTableCellPadding,
          backgroundColor:
              colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        'td': TagflowStyle(
          padding: tableCellPadding ?? defaultTableCellPadding,
        ),

        // Inline elements
        'strong': TagflowStyle(
          textStyle:
              strongStyle ?? const TextStyle(fontWeight: FontWeight.bold),
        ),
        'em': TagflowStyle(
          textStyle: emStyle ?? const TextStyle(fontStyle: FontStyle.italic),
        ),
        'code': TagflowStyle(
          textStyle: codeStyle ??
              textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                backgroundColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
          padding: inlineCodePadding ?? defaultInlineCodePadding,
        ),

        // Add any additional styles
        if (additionalStyles != null) ...additionalStyles,
      },
      namedColors: {
        if (useSystemColors) ..._systemColors(colorScheme),
        if (additionalColors != null) ...additionalColors,
      },
    );
  }

  /// Create a theme optimized for article/blog content
  factory TagflowTheme.article({
    required TextStyle baseTextStyle,
    required TextStyle headingTextStyle,
    double baseFontSize = 18.0,
    double? maxWidth,
    Color? linkColor,
    Color? codeBackground,
    String? codeFontFamily,
    Color? blockquoteBackground,
    Color? blockquoteBorderColor,
    EdgeInsets? contentPadding,
    Map<String, TagflowStyle>? additionalStyles,
  }) {
    return TagflowTheme._(
      defaultStyle: TagflowStyle(
        textStyle: baseTextStyle,
        padding: contentPadding ?? EdgeInsets.all(baseFontSize * 0.5),
      ),
      styles: {
        'p': TagflowStyle(
          maxWidth: maxWidth,
          margin: EdgeInsets.only(bottom: baseFontSize),
          textStyle: baseTextStyle.copyWith(
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
        'h1': TagflowStyle(
          maxWidth: maxWidth,
          textStyle: headingTextStyle.copyWith(
            fontSize: baseFontSize * 2.0,
            fontWeight: FontWeight.w700,
          ),
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.8),
        ),
        'h2': TagflowStyle(
          maxWidth: maxWidth,
          textStyle: headingTextStyle.copyWith(
            fontSize: baseFontSize * 1.5,
            fontWeight: FontWeight.w600,
          ),
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.7),
        ),
        'h3': TagflowStyle(
          maxWidth: maxWidth,
          textStyle: headingTextStyle.copyWith(
            fontSize: baseFontSize * 1.25,
            fontWeight: FontWeight.w600,
          ),
          margin: EdgeInsets.symmetric(vertical: baseFontSize * 0.6),
        ),
        'blockquote': TagflowStyle(
          maxWidth: maxWidth,
          margin: EdgeInsets.symmetric(vertical: baseFontSize),
          padding: EdgeInsets.all(baseFontSize),
          backgroundColor: blockquoteBackground,
          borderLeft: BorderSide(
            color: blockquoteBorderColor ?? Colors.grey,
            width: baseFontSize * 0.25,
          ),
          borderRadius: BorderRadius.circular(baseFontSize * 0.25),
        ),
        'code': TagflowStyle(
          textStyle: baseTextStyle.copyWith(
            fontFamily: codeFontFamily ?? 'monospace',
          ),
          backgroundColor: codeBackground,
          padding: EdgeInsets.symmetric(
            horizontal: baseFontSize * 0.25,
            vertical: baseFontSize * 0.125,
          ),
        ),
        'a': TagflowStyle(
          textStyle: TextStyle(
            color: linkColor ?? Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
        if (additionalStyles != null) ...additionalStyles,
      },
    );
  }

  /// Default style applied to all elements
  final TagflowStyle defaultStyle;

  /// Map of selectors to styles
  final Map<String, TagflowStyle> styles;

  /// Custom named colors mapping
  final Map<String, Color> namedColors;

  /// Get style for an element, merging all applicable styles
  TagflowStyle resolveStyle(TagflowElement element) {
    var result = defaultStyle;

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

    // Add inline styles last
    final inlineStyle = StyleParser.parseInlineStyle(
      element.attributes['style'] ?? '',
      this,
    );
    if (inlineStyle != null) {
      result = result.merge(inlineStyle);
    }

    return result;
  }

  /// Create a copy with some properties replaced
  TagflowTheme copyWith({
    TagflowStyle? defaultStyle,
    Map<String, TagflowStyle>? styles,
    Map<String, Color>? namedColors,
  }) {
    return TagflowTheme._(
      defaultStyle: defaultStyle ?? this.defaultStyle,
      styles: styles ?? this.styles,
      namedColors: namedColors ?? this.namedColors,
    );
  }

  /// Merge two themes
  TagflowTheme merge(TagflowTheme? other) {
    if (other == null) return this;
    return TagflowTheme._(
      defaultStyle: defaultStyle.merge(other.defaultStyle),
      styles: {...styles, ...other.styles},
      namedColors: {...namedColors, ...other.namedColors},
    );
  }

  static Map<String, Color> _systemColors(ColorScheme scheme) => {
        'primary': scheme.primary,
        'onPrimary': scheme.onPrimary,
        'secondary': scheme.secondary,
        'onSecondary': scheme.onSecondary,
        'surface': scheme.surface,
        'onSurface': scheme.onSurface,
        'background': scheme.surface,
        'onBackground': scheme.onSurface,
        'error': scheme.error,
        'onError': scheme.onError,
      };

  @override
  List<Object?> get props => [defaultStyle, styles, namedColors];
}

/// Provides theme to descendant widgets
@protected
class TagflowThemeProvider extends InheritedWidget {
  /// Creates a [TagflowThemeProvider]
  const TagflowThemeProvider({
    required this.theme,
    required super.child,
    super.key,
  });

  /// The theme to provide to descendants
  final TagflowTheme theme;

  /// Get the nearest theme from the widget tree
  static TagflowTheme of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<TagflowThemeProvider>();
    return provider?.theme ?? TagflowTheme.fromTheme(Theme.of(context));
  }

  /// Get the nearest theme without registering for updates
  static TagflowTheme? maybeOf(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<TagflowThemeProvider>();
    return provider?.theme;
  }

  @override
  bool updateShouldNotify(TagflowThemeProvider oldWidget) =>
      theme != oldWidget.theme;
}
