// ignore_for_file: lines_longer_than_80_chars

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
  /// ```
  ///
  /// See also:
  /// - [TagflowTheme.fromTheme] for creating a theme from a Flutter theme.
  /// - [TagflowTheme.article] for creating a theme optimized for article/blog content.
  const TagflowTheme.raw({
    required this.styles,
    required this.defaultStyle,
    this.namedColors = const {},
  });

  /// Creates a theme from a Flutter [ThemeData] with extensive customization options.
  ///
  /// Uses the Flutter theme's text styles and colors as a base, while allowing overrides for:
  /// - Text styles for headings, code, emphasis, etc.
  /// - Spacing and padding for blocks, lists, and tables
  /// - Border widths and colors
  /// - Additional custom styles and colors
  ///
  /// The [useSystemColors] parameter determines whether to use the Flutter theme's
  /// color scheme for named colors. Set to false to only use custom colors.
  ///
  /// Example:
  /// ```dart
  /// final theme = TagflowTheme.fromTheme(
  ///   Theme.of(context),
  ///   baseFontSize: 16.0,
  ///   h1Style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
  ///   additionalColors: {'accent': Colors.purple},
  /// );
  /// ```
  ///
  /// See also:
  /// - [TagflowTheme.article] for creating a theme optimized for article/blog content.
  /// - [TagflowTheme.raw] for creating a theme with raw style definitions.
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
    EdgeInsets? inlineCodeMargin,
    double? borderWidth,
    // Colors
    Color? codeBackground,
  }) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Default spacing values
    final defaultSpacing = EdgeInsets.all(baseFontSize * 0.5);
    final defaultBlockPadding = EdgeInsets.all(baseFontSize);
    final defaultBlockMargin = EdgeInsets.symmetric(vertical: baseFontSize);
    final defaultInlineCodeMargin = EdgeInsets.symmetric(
      vertical: baseFontSize * 0.25,
    );
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
          backgroundColor: codeBackground ??
              colorScheme.surfaceContainerHighest.withAlpha(77),
        ),
        'blockquote': TagflowStyle(
          padding: blockPadding ?? defaultBlockPadding,
          margin: blockMargin ?? defaultBlockMargin,
          backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(26),
          borderLeft: BorderSide(
            color: colorScheme.primary.withAlpha(128),
            width: borderWidth ?? defaultBorderWidth,
          ),
        ),
        ..._defaultStyles(
          baseFontSize,
          linkColor: theme.colorScheme.primary,
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
          backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(26),
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
              ),
          backgroundColor: codeBackground ??
              colorScheme.surfaceContainerHighest.withAlpha(77),
          padding: inlineCodePadding ?? defaultInlineCodePadding,
          margin: inlineCodeMargin ?? defaultInlineCodeMargin,
        ),
        'pre code': const TagflowStyle(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
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

  /// Creates a theme optimized for article and blog content with comfortable reading styles.
  ///
  /// Configures text styles, spacing, and colors suitable for long-form content:
  /// - Larger base font size and line height for readability
  /// - Hierarchical heading styles
  /// - Distinct blockquote and code formatting
  /// - Optional maximum content width
  /// - Customizable link colors and padding
  ///
  /// Example:
  /// ```dart
  /// final theme = TagflowTheme.article(
  ///   baseTextStyle: Theme.of(context).textTheme.bodyMedium!,
  ///   headingTextStyle: Theme.of(context).textTheme.headlineMedium!,
  /// );
  /// ```
  ///
  /// See also:
  /// - [TagflowTheme.fromTheme] for creating a theme from a Flutter theme.
  /// - [TagflowTheme.raw] for creating a theme with raw style definitions.
  factory TagflowTheme.article({
    required TextStyle baseTextStyle,
    required TextStyle headingTextStyle,
    TextStyle? codeTextStyle,
    double baseFontSize = 18.0,
    double? maxWidth,
    Color? linkColor,
    Color? codeBackground,
    String? codeFontFamily,
    Color? blockquoteBackground,
    Color? blockquoteBorderColor,
    EdgeInsets? contentPadding,
    Map<String, TagflowStyle>? additionalStyles,
    Map<String, TagflowStyle> Function(TagflowTheme theme)?
        resolveAdditionalStyles,
  }) {
    final theme = TagflowTheme._(
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
        ),
        'pre': TagflowStyle(
          margin: EdgeInsets.symmetric(vertical: baseFontSize),
          padding: EdgeInsets.all(baseFontSize),
          backgroundColor: codeBackground,
          borderRadius: BorderRadius.circular(baseFontSize * 0.25),
          border: Border.all(
            color: codeBackground?.withAlpha(128) ?? Colors.grey,
          ),
          textStyle: codeTextStyle,
          width: maxWidth ?? double.infinity,
        ),
        'code': TagflowStyle(
          textStyle: codeTextStyle ??
              baseTextStyle.copyWith(
                fontFamily: codeFontFamily ?? 'monospace',
              ),
          backgroundColor: codeBackground,
          padding: EdgeInsets.symmetric(
            horizontal: baseFontSize * 0.25,
            vertical: baseFontSize * 0.125,
          ),
          width: maxWidth ?? double.infinity,
        ),
        'pre code': const TagflowStyle(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
        ),
        'li': TagflowStyle(
          margin: EdgeInsets.only(bottom: baseFontSize),
          padding: EdgeInsets.only(left: baseFontSize * 1.5),
        ),
        ..._defaultStyles(baseFontSize, linkColor: linkColor ?? Colors.blue),
        if (additionalStyles != null) ...additionalStyles,
      },
    );

    if (resolveAdditionalStyles != null) {
      theme.styles.addAll(resolveAdditionalStyles(theme));
    }

    return theme;
  }

  /// Default style applied to all elements
  final TagflowStyle defaultStyle;

  /// Map of selectors to styles
  final Map<String, TagflowStyle> styles;

  /// Custom named colors mapping
  final Map<String, Color> namedColors;

  /// Get style for an element, merging all applicable styles
  TagflowStyle resolveStyle(TagflowNode element) {
    var result = defaultStyle;

    // Add tag style
    if (styles.containsKey(element.tag)) {
      result = result.merge(styles[element.tag]);
    }

    // Add nested styles
    var parent = element.parent;
    while (parent != null) {
      final nestedSelector = '${parent.tag} ${element.tag}';
      if (styles.containsKey(nestedSelector)) {
        result = result.merge(styles[nestedSelector]);
      }
      parent = parent.parent;
    }

    // Add class styles
    final classes = element.attributes?['class']?.split(' ') ?? [];
    for (final className in classes) {
      final classStyle = styles['.${className.trim()}'];
      if (classStyle != null) {
        result = result.merge(classStyle);
      }
    }

    // Add inline styles last
    final inlineStyle = StyleParser.parseInlineStyle(
      element.attributes?['style'] ?? '',
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

  static Map<String, TagflowStyle> _defaultStyles(
    double baseFontSize, {
    Color linkColor = Colors.blue,
    Color markColor = Colors.yellow,
  }) {
    const boldStyle = TextStyle(fontWeight: FontWeight.bold);
    const italicStyle = TextStyle(fontStyle: FontStyle.italic);
    return {
      'small': TagflowStyle(textStyle: TextStyle(fontSize: baseFontSize * 0.8)),
      'b': const TagflowStyle(textStyle: boldStyle),
      'strong': const TagflowStyle(textStyle: boldStyle),
      'i': const TagflowStyle(textStyle: italicStyle),
      'em': const TagflowStyle(textStyle: italicStyle),
      'u': const TagflowStyle(
        textStyle: TextStyle(decoration: TextDecoration.underline),
      ),
      'a': TagflowStyle(
        textStyle: TextStyle(
          color: linkColor,
          decoration: TextDecoration.underline,
          decorationColor: linkColor,
        ),
      ),
      'del': const TagflowStyle(
        textStyle: TextStyle(
          decoration: TextDecoration.lineThrough,
        ),
      ),
      'ins': const TagflowStyle(
        textStyle: TextStyle(
          decoration: TextDecoration.underline,
        ),
      ),
      'mark': TagflowStyle(
        padding: EdgeInsets.symmetric(
          horizontal: baseFontSize * 0.25,
          vertical: baseFontSize * 0.05,
        ),
        borderRadius: BorderRadius.circular(baseFontSize * 0.125),
        backgroundColor: markColor.withAlpha(51),
      ),
      'sub': TagflowStyle(
        textScaleFactor: 0.65,
        padding: EdgeInsets.only(top: baseFontSize * 0.35),
      ),
      'sup': TagflowStyle(
        textScaleFactor: 0.65,
        padding: EdgeInsets.only(bottom: baseFontSize * 0.35),
      ),
    };
  }

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
