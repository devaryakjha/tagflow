// lib/src/style/style_parser.dart
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Utility class to parse CSS-like values into Flutter values
class StyleParser {
  /// CSS named colors mapping
  static const _namedColors = {
    'transparent': Color(0x00000000),
    'black': Color(0xFF000000),
    'white': Color(0xFFFFFFFF),
    'red': Color(0xFFFF0000),
    'green': Color(0xFF00FF00),
    'blue': Color(0xFF0000FF),
    'yellow': Color(0xFFFFFF00),
    // Add more named colors as needed
  };

  /// Default rem size in pixels
  static const _defaultRemSize = 16.0;

  /// Parse a CSS size value with optional unit
  static double? parseSize(String value, [double remSize = _defaultRemSize]) {
    value = value.trim().toLowerCase();

    // Handle percentage values
    if (value.endsWith('%')) {
      final number = double.tryParse(value.replaceAll('%', ''));
      return number != null ? number / 100 : null;
    }

    // Handle various units
    final units = {
      'px': 1.0,
      'rem': remSize,
      'em': remSize,
      'pt': 1.333333, // 1pt = 1.333333px
      'vh': 1.0, // TODO: Implement viewport relative units
      'vw': 1.0,
    };

    for (final unit in units.entries) {
      if (value.endsWith(unit.key)) {
        final number = double.tryParse(value.replaceAll(unit.key, ''));
        return number != null ? number * unit.value : null;
      }
    }

    // Try parsing as raw number
    return double.tryParse(value);
  }

  /// Parse a CSS color value
  static Color? parseColor(String value) {
    value = value.trim().toLowerCase();

    // Check named colors first
    if (_namedColors.containsKey(value)) {
      return _namedColors[value];
    }

    // Handle hex colors
    if (value.startsWith('#')) {
      var hex = value.substring(1);
      if (hex.length == 3) {
        hex = hex.split('').map((c) => '$c$c').join();
      }
      if (hex.length == 6) {
        hex = 'ff$hex'; // Add full opacity
      }
      final intValue = int.tryParse(hex, radix: 16);
      return intValue != null ? Color(intValue) : null;
    }

    // Handle rgb/rgba
    final rgbMatch = RegExp(r'rgba?\((.*?)\)').firstMatch(value);
    if (rgbMatch != null) {
      final parts = rgbMatch.group(1)!.split(',').map((s) => s.trim()).toList();
      try {
        final r = int.parse(parts[0]);
        final g = int.parse(parts[1]);
        final b = int.parse(parts[2]);
        final a = parts.length > 3 ? double.parse(parts[3]) : 1.0;
        return Color.fromRGBO(r, g, b, a);
      } catch (_) {
        return null;
      }
    }

    // Handle hsl/hsla (TODO)
    return null;
  }

  /// Parse CSS font-weight value
  static FontWeight? parseFontWeight(String value) {
    return switch (value.toLowerCase()) {
      '100' || 'thin' => FontWeight.w100,
      '200' || 'extralight' => FontWeight.w200,
      '300' || 'light' => FontWeight.w300,
      '400' || 'normal' || 'regular' => FontWeight.w400,
      '500' || 'medium' => FontWeight.w500,
      '600' || 'semibold' => FontWeight.w600,
      '700' || 'bold' => FontWeight.w700,
      '800' || 'extrabold' => FontWeight.w800,
      '900' || 'black' => FontWeight.w900,
      _ => null,
    };
  }

  /// Parse CSS font-style value
  static FontStyle? parseFontStyle(String value) {
    return switch (value.toLowerCase()) {
      'italic' => FontStyle.italic,
      'normal' => FontStyle.normal,
      _ => null,
    };
  }

  /// Parse CSS text-decoration value
  static TextDecoration? parseTextDecoration(String value) {
    final decorations = value.toLowerCase().split(' ');
    final result = <TextDecoration>[];

    for (final decoration in decorations) {
      switch (decoration) {
        case 'underline':
          result.add(TextDecoration.underline);
        case 'line-through':
          result.add(TextDecoration.lineThrough);
        case 'overline':
          result.add(TextDecoration.overline);
        case 'none':
          return TextDecoration.none;
      }
    }

    return result.isEmpty ? null : TextDecoration.combine(result);
  }

  /// Parse CSS text-align value
  static TextAlign? parseTextAlign(String value) {
    return switch (value.toLowerCase()) {
      'left' => TextAlign.left,
      'right' => TextAlign.right,
      'center' => TextAlign.center,
      'justify' => TextAlign.justify,
      'start' => TextAlign.start,
      'end' => TextAlign.end,
      _ => null,
    };
  }

  /// Parse CSS edge insets (margin, padding)
  static EdgeInsets? parseEdgeInsets(String value) {
    final parts = value.split(' ').map(parseSize).toList();

    return switch (parts.length) {
      1 when parts[0] != null => EdgeInsets.all(parts[0]!),
      2 when parts.every((e) => e != null) => EdgeInsets.symmetric(
          vertical: parts[0]!,
          horizontal: parts[1]!,
        ),
      3 when parts.every((e) => e != null) => EdgeInsets.only(
          top: parts[0]!,
          right: parts[1]!,
          left: parts[1]!,
          bottom: parts[2]!,
        ),
      4 when parts.every((e) => e != null) => EdgeInsets.fromLTRB(
          parts[0]!,
          parts[1]!,
          parts[2]!,
          parts[3]!,
        ),
      _ => null,
    };
  }

  /// Parse CSS border-radius value
  static BorderRadius? parseBorderRadius(String value) {
    final parts = value.split(' ').map(parseSize).toList();

    return switch (parts.length) {
      1 when parts[0] != null => BorderRadius.circular(parts[0]!),
      2 when parts.every((e) => e != null) => BorderRadius.only(
          topLeft: Radius.circular(parts[0]!),
          topRight: Radius.circular(parts[1]!),
          bottomRight: Radius.circular(parts[1]!),
          bottomLeft: Radius.circular(parts[0]!),
        ),
      4 when parts.every((e) => e != null) => BorderRadius.only(
          topLeft: Radius.circular(parts[0]!),
          topRight: Radius.circular(parts[1]!),
          bottomRight: Radius.circular(parts[2]!),
          bottomLeft: Radius.circular(parts[3]!),
        ),
      _ => null,
    };
  }

  /// Parse CSS display value
  static Display? parseDisplay(String value) {
    return switch (value.toLowerCase()) {
      'block' => Display.block,
      'inline' => Display.inline,
      'inline-block' => Display.inlineBlock,
      'flex' => Display.flex,
      'none' => Display.none,
      _ => null,
    };
  }

  /// Parse CSS flex-direction value
  static FlexDirection? parseFlexDirection(String value) {
    return switch (value.toLowerCase()) {
      'row' => FlexDirection.row,
      'row-reverse' => FlexDirection.rowReverse,
      'column' => FlexDirection.column,
      'column-reverse' => FlexDirection.columnReverse,
      _ => null,
    };
  }

  /// Parse CSS justify-content value
  static MainAxisAlignment? parseJustifyContent(String value) {
    return switch (value.toLowerCase()) {
      'flex-start' || 'start' => MainAxisAlignment.start,
      'flex-end' || 'end' => MainAxisAlignment.end,
      'center' => MainAxisAlignment.center,
      'space-between' => MainAxisAlignment.spaceBetween,
      'space-around' => MainAxisAlignment.spaceAround,
      'space-evenly' => MainAxisAlignment.spaceEvenly,
      _ => null,
    };
  }

  /// Parse CSS align-items value
  static CrossAxisAlignment? parseAlignItems(String value) {
    return switch (value.toLowerCase()) {
      'flex-start' || 'start' => CrossAxisAlignment.start,
      'flex-end' || 'end' => CrossAxisAlignment.end,
      'center' => CrossAxisAlignment.center,
      'stretch' => CrossAxisAlignment.stretch,
      'baseline' => CrossAxisAlignment.baseline,
      _ => null,
    };
  }

  /// Parse inline style string into TagflowStyle
  static TagflowStyle? parseInlineStyle(String? styleString) {
    if (styleString == null || styleString.isEmpty) return null;

    final styles = _parseDeclarations(styleString);
    if (styles.isEmpty) return null;

    return TagflowStyle(
      textStyle: _parseTextStyle(styles),
      padding: styles['padding'] != null
          ? parseEdgeInsets(styles['padding']!)
          : null,
      margin:
          styles['margin'] != null ? parseEdgeInsets(styles['margin']!) : null,
      backgroundColor: styles['background-color'] != null
          ? parseColor(styles['background-color']!)
          : null,
      alignment: _parseAlignment(styles),
      textAlign: styles['text-align'] != null
          ? parseTextAlign(styles['text-align']!)
          : null,
      // Add layout property parsing
      display: parseDisplay(styles['display'] ?? 'block') ?? Display.block,
      flexDirection: styles['flex-direction'] != null
          ? _parseFlexDirection(styles['flex-direction']!)
          : null,
      justifyContent: styles['justify-content'] != null
          ? parseJustifyContent(styles['justify-content']!)
          : null,
      alignItems: styles['align-items'] != null
          ? parseAlignItems(styles['align-items']!)
          : null,
      gap: styles['gap'] != null ? parseSize(styles['gap']!) : null,
    );
  }

  /// Parse CSS declarations into a map
  static Map<String, String> _parseDeclarations(String styleString) {
    return Map.fromEntries(
      styleString
          .split(';')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((declaration) {
        final parts = declaration.split(':').map((s) => s.trim()).toList();
        return parts.length == 2 ? MapEntry(parts[0], parts[1]) : null;
      }).whereType<MapEntry<String, String>>(),
    );
  }

  /// Parse text-related styles into TextStyle
  static TextStyle? _parseTextStyle(Map<String, String> styles) {
    return TextStyle(
      color: styles['color'] != null ? parseColor(styles['color']!) : null,
      fontSize:
          styles['font-size'] != null ? parseSize(styles['font-size']!) : null,
      fontWeight: styles['font-weight'] != null
          ? parseFontWeight(styles['font-weight']!)
          : null,
      fontStyle: styles['font-style'] != null
          ? parseFontStyle(styles['font-style']!)
          : null,
      decoration: styles['text-decoration'] != null
          ? parseTextDecoration(styles['text-decoration']!)
          : null,
    );
  }

  /// Parse alignment-related styles
  static Alignment? _parseAlignment(Map<String, String> styles) {
    if (styles['text-align'] != null) {
      return switch (styles['text-align']!.toLowerCase()) {
        'left' => Alignment.centerLeft,
        'right' => Alignment.centerRight,
        'center' => Alignment.center,
        _ => null,
      };
    }
    return null;
  }

  /// Parse transform-related styles
  static Matrix4? _parseTransform(Map<String, String> styles) {
    // TODO: Implement transform parsing (rotate, scale, translate, etc.)
    return null;
  }

  /// Parse decoration-related styles
  static BoxDecoration? _parseDecoration(Map<String, String> styles) {
    final hasDecoration = styles.keys.any(
      (key) =>
          key.startsWith('border') ||
          key == 'background-color' ||
          key == 'border-radius',
    );

    if (!hasDecoration) return null;

    return BoxDecoration(
      color: styles['background-color'] != null
          ? parseColor(styles['background-color']!)
          : null,
      borderRadius: styles['border-radius'] != null
          ? parseBorderRadius(styles['border-radius']!)
          : null,
      // TODO: Add border parsing
    );
  }

  /// Parse flex-direction into Axis
  static Axis? _parseFlexDirection(String value) {
    return switch (value.toLowerCase()) {
      'row' || 'row-reverse' => Axis.horizontal,
      'column' || 'column-reverse' => Axis.vertical,
      _ => null,
    };
  }

  /// Parse CSS object-fit value into BoxFit
  static BoxFit? parseBoxFit(String value) {
    return switch (value.toLowerCase()) {
      'contain' => BoxFit.contain,
      'cover' => BoxFit.cover,
      'fill' => BoxFit.fill,
      'none' => BoxFit.none,
      'scale-down' => BoxFit.scaleDown,
      'fit' => BoxFit.fitWidth, // Non-standard, but useful
      'width' => BoxFit.fitWidth,
      'height' => BoxFit.fitHeight,
      _ => null,
    };
  }
}
