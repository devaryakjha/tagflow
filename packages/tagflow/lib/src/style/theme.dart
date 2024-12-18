import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/tagflow.dart';

/// A theme that provides default styles for all HTML elements in Tagflow.
class TagflowTheme extends Equatable {
  /// Create a new [TagflowTheme]
  const TagflowTheme({
    this.styles = const {},
    this.namedColors = const {},
    this.defaultStyle = const TagflowStyle(),
  });

  /// Create a theme with basic styles
  factory TagflowTheme.basic({
    TextStyle? textStyle,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Map<String, Color>? colors,
  }) {
    return TagflowTheme(
      defaultStyle: TagflowStyle(
        textStyle: textStyle,
        padding: padding,
        margin: margin,
      ),
      namedColors: colors ?? const {},
    );
  }

  /// Create a new theme from a Flutter theme with customization options
  factory TagflowTheme.fromTheme(
    ThemeData theme, {
    Map<String, TagflowStyle>? additionalStyles,
    Map<String, Color>? additionalColors,
    double baseSize = 16.0,
    TagflowHeadingConfig? headingConfig,
    TagflowSpacingConfig? spacingConfig,
    bool useSystemColors = true,
  }) {
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final spacing = spacingConfig ?? TagflowSpacingConfig(baseSize: baseSize);
    final headings = headingConfig ?? TagflowHeadingConfig(baseSize: baseSize);

    return TagflowTheme(
      defaultStyle: TagflowStyle(
        textStyle: textTheme.bodyMedium,
        padding: spacing.defaultPadding,
      ),
      styles: {
        // Text elements
        'p': TagflowStyle(
          margin: spacing.paragraphMargin,
        ),
        'h1': headings.h1Style,
        'h2': headings.h2Style,
        'h3': headings.h3Style,
        'h4': headings.h4Style,
        'h5': headings.h5Style,
        'h6': headings.h6Style,

        // Inline elements
        'strong': const TagflowStyle(
          textStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        'em': const TagflowStyle(
          textStyle: TextStyle(fontStyle: FontStyle.italic),
        ),
        'code': TagflowStyle(
          textStyle: textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            backgroundColor:
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          padding: spacing.inlineCodePadding,
        ),

        // Block elements
        'pre': TagflowStyle(
          padding: spacing.blockPadding,
          margin: spacing.blockMargin,
          backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.1),
        ),
        'blockquote': TagflowStyle(
          padding: spacing.blockPadding,
          margin: spacing.blockMargin,
          backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.1),
          borderLeft: BorderSide(
            color: colorScheme.primary.withOpacity(0.5),
            width: spacing.borderWidth,
          ),
        ),

        // Lists
        'ul': TagflowStyle(
          padding: spacing.listPadding,
          margin: spacing.blockMargin,
        ),
        'ol': TagflowStyle(
          padding: spacing.listPadding,
          margin: spacing.blockMargin,
        ),

        // Tables
        'table': TagflowStyle(
          margin: spacing.blockMargin,
          border: Border.all(
            color: colorScheme.outline,
            width: spacing.borderWidth,
          ),
        ),
        'th': TagflowStyle(
          padding: spacing.tableCellPadding,
          backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.1),
          textStyle: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        'td': TagflowStyle(
          padding: spacing.tableCellPadding,
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

  /// Create a minimal theme with just essential styles
  factory TagflowTheme.minimal({
    required TextStyle baseStyle,
    Color? linkColor,
    Map<String, Color>? colors,
  }) {
    return TagflowTheme(
      defaultStyle: TagflowStyle(textStyle: baseStyle),
      styles: {
        'a': TagflowStyle(
          textStyle: TextStyle(
            color: linkColor ?? Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      },
      namedColors: colors ?? const {},
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
    return TagflowTheme(
      defaultStyle: defaultStyle ?? this.defaultStyle,
      styles: styles ?? this.styles,
      namedColors: namedColors ?? this.namedColors,
    );
  }

  /// Merge two themes
  TagflowTheme merge(TagflowTheme? other) {
    if (other == null) return this;
    return TagflowTheme(
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

/// Configuration for heading styles
class TagflowHeadingConfig {
  const TagflowHeadingConfig({
    double baseSize = 16.0,
    this.scales = const [2.0, 1.75, 1.5, 1.25, 1.125, 1.0],
    this.weights = const [
      FontWeight.w800,
      FontWeight.w700,
      FontWeight.w600,
      FontWeight.w500,
      FontWeight.w500,
      FontWeight.w400,
    ],
    this.margins,
  }) : _baseSize = baseSize;

  final double _baseSize;
  final List<double> scales;
  final List<FontWeight> weights;
  final List<EdgeInsets>? margins;

  TagflowStyle get h1Style => _headingStyle(0);
  TagflowStyle get h2Style => _headingStyle(1);
  TagflowStyle get h3Style => _headingStyle(2);
  TagflowStyle get h4Style => _headingStyle(3);
  TagflowStyle get h5Style => _headingStyle(4);
  TagflowStyle get h6Style => _headingStyle(5);

  TagflowStyle _headingStyle(int level) {
    return TagflowStyle(
      textStyle: TextStyle(
        fontSize: _baseSize * scales[level],
        fontWeight: weights[level],
      ),
      margin: margins?[level] ??
          EdgeInsets.symmetric(
            vertical: _baseSize * scales[level] * 0.5,
          ),
    );
  }
}

/// Configuration for spacing in the theme
class TagflowSpacingConfig {
  const TagflowSpacingConfig({
    double baseSize = 16.0,
    this.scale = 1.0,
  }) : _baseSize = baseSize;

  final double _baseSize;
  final double scale;

  double get unit => _baseSize * scale;

  EdgeInsets get defaultPadding => EdgeInsets.all(unit * 0.5);
  EdgeInsets get blockPadding => EdgeInsets.all(unit);
  EdgeInsets get blockMargin => EdgeInsets.symmetric(vertical: unit);
  EdgeInsets get paragraphMargin => EdgeInsets.only(bottom: unit);
  EdgeInsets get listPadding => EdgeInsets.only(left: unit * 1.5);
  EdgeInsets get tableCellPadding => EdgeInsets.all(unit * 0.5);
  EdgeInsets get inlineCodePadding => EdgeInsets.symmetric(
        horizontal: unit * 0.25,
        vertical: unit * 0.125,
      );

  double get borderWidth => unit * 0.25;
}

/// Provides theme to descendant widgets
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
