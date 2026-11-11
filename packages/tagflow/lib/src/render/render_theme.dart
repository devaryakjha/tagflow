import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tagflow/src/style/theme.dart';

/// Typed styling for the built-in components of the runtime renderer.
///
/// Every field is optional. Unset fields fall back to defaults derived from
/// the ambient [Theme] and [DefaultTextStyle], so dark mode and the app's
/// typography work with no setup. Text styles are merged over those
/// defaults, so `TagflowRenderTheme(h1Style: TextStyle(fontSize: 40))` keeps
/// the default heading weight and only changes the size.
///
/// Provide one through `Tagflow.*(renderTheme: ...)`, or for a whole subtree
/// with [TagflowRenderThemeScope]. A `TagflowTheme` passed as `theme:` is
/// mapped onto this type with [TagflowRenderTheme.fromTagflowTheme].
@immutable
final class TagflowRenderTheme with Diagnosticable {
  /// Creates a render theme. Unset fields use the ambient defaults.
  const TagflowRenderTheme({
    this.textStyle,
    this.paragraphStyle,
    this.h1Style,
    this.h2Style,
    this.h3Style,
    this.h4Style,
    this.h5Style,
    this.h6Style,
    this.linkStyle,
    this.strongStyle,
    this.emphasisStyle,
    this.inlineCodeStyle,
    this.codeBlockStyle,
    this.blockquoteStyle,
    this.tableHeaderStyle,
    this.paragraphSpacing,
    this.blockSpacing,
    this.listItemSpacing,
    this.borderColor,
    this.codeBackgroundColor,
    this.quoteBackgroundColor,
    this.quoteBorderColor,
    this.tableHeaderBackgroundColor,
    this.highlightColor,
  });

  /// Maps the named styles of a legacy [TagflowTheme] onto a render theme.
  ///
  /// Reads the default text style and the `p`, `h1` to `h6`, `a`, `strong`,
  /// `em`, `code`, `pre`, `blockquote`, `th` and `mark` entries. Other
  /// selectors, such as classes and nested selectors, only apply to the
  /// legacy converter pipeline.
  factory TagflowRenderTheme.fromTagflowTheme(TagflowTheme theme) {
    final styles = theme.styles;
    final blockquote = styles['blockquote'];
    return TagflowRenderTheme(
      textStyle: theme.defaultStyle.textStyle,
      paragraphStyle: styles['p']?.textStyle,
      h1Style: styles['h1']?.textStyle,
      h2Style: styles['h2']?.textStyle,
      h3Style: styles['h3']?.textStyle,
      h4Style: styles['h4']?.textStyle,
      h5Style: styles['h5']?.textStyle,
      h6Style: styles['h6']?.textStyle,
      linkStyle: styles['a']?.textStyle,
      strongStyle: styles['strong']?.textStyle,
      emphasisStyle: styles['em']?.textStyle,
      inlineCodeStyle: styles['code']?.textStyle,
      codeBlockStyle: styles['pre']?.textStyle,
      blockquoteStyle: blockquote?.textStyle,
      tableHeaderStyle: styles['th']?.textStyle,
      codeBackgroundColor:
          styles['code']?.backgroundColor ?? styles['pre']?.backgroundColor,
      quoteBackgroundColor: blockquote?.backgroundColor,
      quoteBorderColor: blockquote?.borderLeft?.color,
      tableHeaderBackgroundColor: styles['th']?.backgroundColor,
      highlightColor: styles['mark']?.backgroundColor,
    );
  }

  /// The defaults for [context], with every field set.
  ///
  /// Typography comes from [ThemeData.textTheme] (headings use the headline
  /// and title styles, bold) without their colours, so text keeps the
  /// ambient [DefaultTextStyle] colour. Surfaces and borders are tinted from
  /// that colour, so they keep their contrast on light and dark backgrounds.
  factory TagflowRenderTheme.defaults(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ink =
        DefaultTextStyle.of(context).style.color ?? const Color(0xFF000000);

    TextStyle heading(TextStyle? base) {
      return TextStyle(
        fontSize: base?.fontSize,
        height: base?.height,
        letterSpacing: base?.letterSpacing,
        fontFamily: base?.fontFamily,
        fontFamilyFallback: base?.fontFamilyFallback,
        fontWeight: FontWeight.w700,
      );
    }

    final linkColor = ink.computeLuminance() > 0.5
        ? const Color(0xFF8AB4F8)
        : const Color(0xFF0B57D0);

    return TagflowRenderTheme(
      textStyle: const TextStyle(),
      paragraphStyle: const TextStyle(),
      h1Style: heading(textTheme.headlineLarge),
      h2Style: heading(textTheme.headlineMedium),
      h3Style: heading(textTheme.headlineSmall),
      h4Style: heading(textTheme.titleLarge),
      h5Style: heading(textTheme.titleMedium),
      h6Style: heading(textTheme.titleSmall),
      linkStyle: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      strongStyle: const TextStyle(fontWeight: FontWeight.w700),
      emphasisStyle: const TextStyle(fontStyle: FontStyle.italic),
      inlineCodeStyle: const TextStyle(fontFamily: 'monospace'),
      codeBlockStyle: const TextStyle(fontFamily: 'monospace'),
      blockquoteStyle: const TextStyle(),
      tableHeaderStyle: const TextStyle(fontWeight: FontWeight.w700),
      paragraphSpacing: 8,
      blockSpacing: 12,
      listItemSpacing: 4,
      borderColor: ink.withAlpha(0x1F),
      codeBackgroundColor: ink.withAlpha(0x12),
      quoteBackgroundColor: ink.withAlpha(0x14),
      quoteBorderColor: const Color(0x661F4B99),
      tableHeaderBackgroundColor: ink.withAlpha(0x12),
      highlightColor: const Color(0x33FFE082),
    );
  }

  /// The resolved render theme for [context]: [TagflowRenderTheme.defaults]
  /// with the nearest [TagflowRenderThemeScope] merged over it.
  ///
  /// Every field of the result is set.
  // ignore: prefer_constructors_over_static_methods, Flutter's `of` lookup.
  static TagflowRenderTheme of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_TagflowResolvedRenderTheme>();
    return scope?.theme ?? TagflowRenderTheme.defaults(context);
  }

  /// Base text style for all content.
  final TextStyle? textStyle;

  /// Text style for paragraphs.
  final TextStyle? paragraphStyle;

  /// Text style for level 1 headings.
  final TextStyle? h1Style;

  /// Text style for level 2 headings.
  final TextStyle? h2Style;

  /// Text style for level 3 headings.
  final TextStyle? h3Style;

  /// Text style for level 4 headings.
  final TextStyle? h4Style;

  /// Text style for level 5 headings.
  final TextStyle? h5Style;

  /// Text style for level 6 headings.
  final TextStyle? h6Style;

  /// Text style for links.
  final TextStyle? linkStyle;

  /// Text style for strong text, such as `<strong>` or Markdown `**bold**`.
  final TextStyle? strongStyle;

  /// Text style for emphasized text, such as `<em>` or Markdown `*italic*`.
  final TextStyle? emphasisStyle;

  /// Text style for inline code.
  final TextStyle? inlineCodeStyle;

  /// Text style for code blocks.
  final TextStyle? codeBlockStyle;

  /// Text style for blockquotes.
  final TextStyle? blockquoteStyle;

  /// Text style for table header cells.
  final TextStyle? tableHeaderStyle;

  /// Space below paragraphs, lists and similar text blocks.
  final double? paragraphSpacing;

  /// Space below code blocks, blockquotes and tables.
  final double? blockSpacing;

  /// Space below each list item.
  final double? listItemSpacing;

  /// Colour of table, code block and horizontal rule borders.
  final Color? borderColor;

  /// Background of code blocks and inline code.
  final Color? codeBackgroundColor;

  /// Background of blockquotes.
  final Color? quoteBackgroundColor;

  /// Colour of the blockquote side border.
  final Color? quoteBorderColor;

  /// Background of table header cells.
  final Color? tableHeaderBackgroundColor;

  /// Background of highlighted (`<mark>`) text.
  final Color? highlightColor;

  /// Text style for a heading of [level] (clamped to 1 to 6).
  TextStyle? headingStyle(int level) {
    return switch (level.clamp(1, 6)) {
      1 => h1Style,
      2 => h2Style,
      3 => h3Style,
      4 => h4Style,
      5 => h5Style,
      _ => h6Style,
    };
  }

  /// Returns a copy with the set fields of [other] applied over this theme.
  ///
  /// Text styles are merged with [TextStyle.merge]; other fields are
  /// replaced.
  TagflowRenderTheme merge(TagflowRenderTheme? other) {
    if (other == null) return this;
    TextStyle? style(TextStyle? base, TextStyle? over) {
      if (base == null) return over;
      return base.merge(over);
    }

    return TagflowRenderTheme(
      textStyle: style(textStyle, other.textStyle),
      paragraphStyle: style(paragraphStyle, other.paragraphStyle),
      h1Style: style(h1Style, other.h1Style),
      h2Style: style(h2Style, other.h2Style),
      h3Style: style(h3Style, other.h3Style),
      h4Style: style(h4Style, other.h4Style),
      h5Style: style(h5Style, other.h5Style),
      h6Style: style(h6Style, other.h6Style),
      linkStyle: style(linkStyle, other.linkStyle),
      strongStyle: style(strongStyle, other.strongStyle),
      emphasisStyle: style(emphasisStyle, other.emphasisStyle),
      inlineCodeStyle: style(inlineCodeStyle, other.inlineCodeStyle),
      codeBlockStyle: style(codeBlockStyle, other.codeBlockStyle),
      blockquoteStyle: style(blockquoteStyle, other.blockquoteStyle),
      tableHeaderStyle: style(tableHeaderStyle, other.tableHeaderStyle),
      paragraphSpacing: other.paragraphSpacing ?? paragraphSpacing,
      blockSpacing: other.blockSpacing ?? blockSpacing,
      listItemSpacing: other.listItemSpacing ?? listItemSpacing,
      borderColor: other.borderColor ?? borderColor,
      codeBackgroundColor: other.codeBackgroundColor ?? codeBackgroundColor,
      quoteBackgroundColor: other.quoteBackgroundColor ?? quoteBackgroundColor,
      quoteBorderColor: other.quoteBorderColor ?? quoteBorderColor,
      tableHeaderBackgroundColor:
          other.tableHeaderBackgroundColor ?? tableHeaderBackgroundColor,
      highlightColor: other.highlightColor ?? highlightColor,
    );
  }

  List<Object?> get _props => [
    textStyle,
    paragraphStyle,
    h1Style,
    h2Style,
    h3Style,
    h4Style,
    h5Style,
    h6Style,
    linkStyle,
    strongStyle,
    emphasisStyle,
    inlineCodeStyle,
    codeBlockStyle,
    blockquoteStyle,
    tableHeaderStyle,
    paragraphSpacing,
    blockSpacing,
    listItemSpacing,
    borderColor,
    codeBackgroundColor,
    quoteBackgroundColor,
    quoteBorderColor,
    tableHeaderBackgroundColor,
    highlightColor,
  ];

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TagflowRenderTheme && listEquals(other._props, _props);
  }

  @override
  int get hashCode => Object.hashAll(_props);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    const fields = [
      'textStyle',
      'paragraphStyle',
      'h1Style',
      'h2Style',
      'h3Style',
      'h4Style',
      'h5Style',
      'h6Style',
      'linkStyle',
      'strongStyle',
      'emphasisStyle',
      'inlineCodeStyle',
      'codeBlockStyle',
      'blockquoteStyle',
      'tableHeaderStyle',
      'paragraphSpacing',
      'blockSpacing',
      'listItemSpacing',
      'borderColor',
      'codeBackgroundColor',
      'quoteBackgroundColor',
      'quoteBorderColor',
      'tableHeaderBackgroundColor',
      'highlightColor',
    ];
    final values = _props;
    for (var i = 0; i < fields.length; i++) {
      properties.add(
        DiagnosticsProperty<Object>(fields[i], values[i], defaultValue: null),
      );
    }
  }
}

/// Provides a [TagflowRenderTheme] to the Tagflow content below it.
///
/// [theme] is merged over the enclosing scope (or over
/// [TagflowRenderTheme.defaults] at this point in the tree), so scopes nest.
final class TagflowRenderThemeScope extends StatelessWidget {
  /// Creates a scope that applies [theme] to the Tagflow content in [child].
  const TagflowRenderThemeScope({
    required this.theme,
    required this.child,
    super.key,
  });

  /// Theme merged over the enclosing render theme.
  final TagflowRenderTheme? theme;

  /// Content the theme applies to.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _TagflowResolvedRenderTheme(
      theme: TagflowRenderTheme.of(context).merge(theme),
      child: child,
    );
  }
}

final class _TagflowResolvedRenderTheme extends InheritedWidget {
  const _TagflowResolvedRenderTheme({
    required this.theme,
    required super.child,
  });

  final TagflowRenderTheme theme;

  @override
  bool updateShouldNotify(_TagflowResolvedRenderTheme oldWidget) {
    return theme != oldWidget.theme;
  }
}
