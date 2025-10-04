import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Utility class to parse CSS-like values into Flutter values
class StyleParser {
  // Cached RegEx patterns for performance
  static final _hexColorRegex = RegExp(r'^[0-9a-f]{8}$');
  static final _rgbaRegex = RegExp(r'rgba?\((.*?)\)');
  static final _shadowSplitRegex = RegExp(r',(?![^(]*\))');
  static final _colorPartRegex = RegExp(r'rgba?\(|#');
  static final _transformFuncRegex = RegExp(r'(\w+)\((.*?)\)');

  // Cached enum lookup maps for performance
  static const _fontWeightMap = {
    '100': FontWeight.w100,
    'thin': FontWeight.w100,
    '200': FontWeight.w200,
    'extralight': FontWeight.w200,
    '300': FontWeight.w300,
    'light': FontWeight.w300,
    '400': FontWeight.w400,
    'normal': FontWeight.w400,
    'regular': FontWeight.w400,
    '500': FontWeight.w500,
    'medium': FontWeight.w500,
    '600': FontWeight.w600,
    'semibold': FontWeight.w600,
    '700': FontWeight.w700,
    'bold': FontWeight.w700,
    '800': FontWeight.w800,
    'extrabold': FontWeight.w800,
    '900': FontWeight.w900,
    'black': FontWeight.w900,
  };

  static const _fontStyleMap = {
    'italic': FontStyle.italic,
    'normal': FontStyle.normal,
  };

  static const _textAlignMap = {
    'left': TextAlign.left,
    'right': TextAlign.right,
    'center': TextAlign.center,
    'justify': TextAlign.justify,
    'start': TextAlign.start,
    'end': TextAlign.end,
  };

  static const _displayMap = {
    'block': Display.block,
    'inline': Display.inline,
    'flex': Display.flex,
    'none': Display.none,
  };

  /// Parse a CSS color value
  static Color? parseColor(String value0, [Map<String, Color>? namedColors]) {
    final value = value0.trim().toLowerCase();
    if (value.isEmpty) return null;

    namedColors ??= const {};

    // Check named colors first
    if (namedColors.containsKey(value)) {
      return namedColors[value];
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
      if (hex.length != 8 || !_hexColorRegex.hasMatch(hex)) {
        return null;
      }
      final intValue = int.tryParse(hex, radix: 16);
      return intValue != null ? Color(intValue) : null;
    }

    // Handle rgb/rgba
    final rgbMatch = _rgbaRegex.firstMatch(value);
    if (rgbMatch != null) {
      final parts = rgbMatch.group(1)!.split(',').map((s) => s.trim()).toList();
      try {
        if (parts.length < 3 || parts.length > 4) return null;

        final r = int.parse(parts[0]);
        final g = int.parse(parts[1]);
        final b = int.parse(parts[2]);
        final a = parts.length > 3 ? double.parse(parts[3]) : 1.0;

        if (r < 0 ||
            r > 255 ||
            g < 0 ||
            g > 255 ||
            b < 0 ||
            b > 255 ||
            a < 0 ||
            a > 1) {
          return null;
        }

        // Convert alpha from 0-1 to 0-255 and ensure it's rounded properly
        final alpha = (a * 255).round();
        return Color.fromARGB(alpha, r, g, b);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Default rem size in pixels
  static const _defaultRemSize = 16.0;

  /// Parse a CSS size value into a SizeValue
  /// object that can handle percentage and viewport units
  static SizeValue? parseSizeValue(
    String value0, [
    double remSize = _defaultRemSize,
  ]) {
    final value = value0.trim().toLowerCase();

    // Handle percentage values
    if (value.endsWith('%')) {
      final number = double.tryParse(value.substring(0, value.length - 1));
      return number != null ? SizeValue(number, SizeUnit.percentage) : null;
    }

    // Handle rem values
    if (value.endsWith('rem')) {
      final number = double.tryParse(value.substring(0, value.length - 3));
      return number != null ? SizeValue(number, SizeUnit.rem) : null;
    }

    // Handle em values
    if (value.endsWith('em')) {
      final number = double.tryParse(value.substring(0, value.length - 2));
      return number != null ? SizeValue(number, SizeUnit.rem) : null;
    }

    // Handle viewport height
    if (value.endsWith('vh')) {
      final number = double.tryParse(value.substring(0, value.length - 2));
      return number != null ? SizeValue(number, SizeUnit.vh) : null;
    }

    // Handle viewport width
    if (value.endsWith('vw')) {
      final number = double.tryParse(value.substring(0, value.length - 2));
      return number != null ? SizeValue(number, SizeUnit.vw) : null;
    }

    // Handle pixel values or raw numbers (default to pixels)
    if (value.endsWith('px')) {
      final number = double.tryParse(value.substring(0, value.length - 2));
      return number != null ? SizeValue(number) : null;
    }

    if (value.endsWith('pt')) {
      final number = double.tryParse(value.substring(0, value.length - 2));
      return number != null ? SizeValue(number, SizeUnit.pt) : null;
    }

    final number = double.tryParse(value);
    return number != null ? SizeValue(number) : null;
  }

  /// Parse a CSS size value with optional unit, returning a direct pixel value
  /// Note: This will return null for percentage and viewport-relative values
  static double? parseSize(String value0, [double remSize = _defaultRemSize]) {
    final sizeValue = parseSizeValue(value0, remSize);
    if (sizeValue == null) return null;

    // Only return absolute pixel values, null for relative values
    switch (sizeValue.unit) {
      case SizeUnit.px:
        return sizeValue.value;
      case SizeUnit.pt:
        return sizeValue.value;
      case SizeUnit.rem:
        return sizeValue.value * remSize;
      case SizeUnit.percentage:
      case SizeUnit.vh:
      case SizeUnit.vw:
        return null;
    }
  }

  /// Parse CSS font-weight value
  static FontWeight? parseFontWeight(String value) {
    return _fontWeightMap[value.toLowerCase()];
  }

  /// Parse CSS font-style value
  static FontStyle? parseFontStyle(String value) {
    return _fontStyleMap[value.toLowerCase()];
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
    return _textAlignMap[value.toLowerCase()];
  }

  /// Parse CSS edge insets (margin, padding)
  static EdgeInsets? parseEdgeInsets(String value) {
    final strParts = value.split(' ');

    if (strParts.length == 1) {
      // Handle special case for '0' - return null not EdgeInsets.zero
      if (strParts[0] == '0') return null;
      final v = parseSize(strParts[0]);
      return v != null ? EdgeInsets.all(v) : null;
    }

    if (strParts.length == 2) {
      final v = strParts[0] == '0' ? 0.0 : parseSize(strParts[0]);
      final h = strParts[1] == '0' ? 0.0 : parseSize(strParts[1]);
      if (v == null || h == null) return null;
      return EdgeInsets.symmetric(vertical: v, horizontal: h);
    }

    if (strParts.length == 3) {
      final top = strParts[0] == '0' ? 0.0 : parseSize(strParts[0]);
      final horiz = strParts[1] == '0' ? 0.0 : parseSize(strParts[1]);
      final bottom = strParts[2] == '0' ? 0.0 : parseSize(strParts[2]);
      if (top == null || horiz == null || bottom == null) return null;
      return EdgeInsets.only(
        top: top,
        right: horiz,
        left: horiz,
        bottom: bottom,
      );
    }

    if (strParts.length == 4) {
      final part0 = strParts[0] == '0' ? 0.0 : parseSize(strParts[0]);
      final part1 = strParts[1] == '0' ? 0.0 : parseSize(strParts[1]);
      final part2 = strParts[2] == '0' ? 0.0 : parseSize(strParts[2]);
      final part3 = strParts[3] == '0' ? 0.0 : parseSize(strParts[3]);
      if (part0 == null || part1 == null || part2 == null || part3 == null) {
        return null;
      }
      return EdgeInsets.fromLTRB(part0, part1, part2, part3);
    }

    return null;
  }

  /// Parse CSS border-radius value
  static BorderRadius? parseBorderRadius(String value) {
    if (value == '0') return null;
    final sizeValue = parseSizeValue(value);
    if (sizeValue == null) return null;

    // For border-radius, we can only use absolute values
    switch (sizeValue.unit) {
      case SizeUnit.px:
      case SizeUnit.pt:
        return BorderRadius.circular(sizeValue.value);
      case SizeUnit.rem:
        return BorderRadius.circular(sizeValue.value * _defaultRemSize);
      case SizeUnit.percentage:
      case SizeUnit.vh:
      case SizeUnit.vw:
        return null;
    }
  }

  /// Parse CSS border value
  static Border? parseBorder(String value) {
    final parts = value.split(' ');
    if (parts.length < 2) return null;

    final width = _sizeValueToPixels(parseSizeValue(parts[0]));
    if (width == null) return null;

    final style = parts[1].toLowerCase();
    final color = parts.length > 2 ? parseColor(parts[2]) : Colors.black;

    return switch (style) {
      'solid' => Border.all(width: width, color: color ?? Colors.black),
      'none' => null,
      _ => null,
    };
  }

  /// Helper method to convert SizeValue to pixels (for box shadow, border)
  static double? _sizeValueToPixels(SizeValue? sizeValue) {
    if (sizeValue == null) return null;
    return switch (sizeValue.unit) {
      SizeUnit.px || SizeUnit.pt => sizeValue.value,
      SizeUnit.rem => sizeValue.value * _defaultRemSize,
      _ => null,
    };
  }

  /// Parse CSS box-shadow value
  static List<BoxShadow>? parseBoxShadow(String value) {
    final shadows = <BoxShadow>[];
    final shadowStrings = value.split(_shadowSplitRegex);

    for (final shadowString in shadowStrings) {
      final parts = shadowString.trim().split(' ');
      if (parts.length < 4) continue;

      try {
        final x = _sizeValueToPixels(parseSizeValue(parts[0]));
        final y = _sizeValueToPixels(parseSizeValue(parts[1]));
        final blur = _sizeValueToPixels(parseSizeValue(parts[2]));
        final spread =
            parts.length > 3
                ? _sizeValueToPixels(parseSizeValue(parts[3])) ?? 0.0
                : 0.0;

        if (x == null || y == null || blur == null) continue;

        final colorStr =
            parts.any(_colorPartRegex.hasMatch)
                ? parts.firstWhere(_colorPartRegex.hasMatch)
                : 'rgba(0,0,0,0.2)';
        final color =
            parseColor(colorStr) ?? Colors.black.withValues(alpha: 0.2);

        shadows.add(
          BoxShadow(
            color: color,
            offset: Offset(x, y),
            blurRadius: blur,
            spreadRadius: spread,
          ),
        );
      } catch (e) {
        continue;
      }
    }

    return shadows.isEmpty ? null : shadows;
  }

  /// Parse CSS transform
  static Matrix4? parseTransform(String value) {
    if (value.isEmpty) return null;

    final transform = Matrix4.identity();
    final transforms = value
        .split(RegExp(r'\)\s+'))
        .map((t) => '$t)')
        .where((t) => t.endsWith(')'));

    for (final t in transforms) {
      final match = _transformFuncRegex.firstMatch(t);
      if (match == null) return null;

      final function = match.group(1)!.toLowerCase();
      final args =
          match.group(2)!.split(',').map((s) => parseSize(s.trim())).toList();

      if (args.any((arg) => arg == null)) return null;

      final values = args.map((a) => a!).toList();

      switch (function) {
        case 'translate':
          if (values.length >= 2) {
            transform.translateByDouble(
              values[0],
              values[1],
              values.length > 2 ? values[2] : 0,
              1,
            );
          } else {
            return null;
          }
        case 'scale':
          if (values.isNotEmpty) {
            transform.scaleByDouble(
              values[0],
              values.length > 1 ? values[1] : values[0],
              values.length > 2 ? values[2] : 1,
              1,
            );
          } else {
            return null;
          }
        case 'rotate':
          if (values.isNotEmpty) {
            transform.rotateZ(values[0] * (3.1415926535897932 / 180));
          } else {
            return null;
          }
        case 'skew':
          if (values.length >= 2) {
            transform
              ..setEntry(1, 0, values[0])
              ..setEntry(0, 1, values[1]);
          } else {
            return null;
          }
        default:
          return null;
      }
    }

    return transform;
  }

  /// Parse CSS display value
  static Display parseDisplay(String value) {
    return _displayMap[value.toLowerCase()] ?? Display.block;
  }

  /// Parse CSS flex-direction value
  static FlexDirection? parseFlexDirection(String value) => switch (value
      .toLowerCase()) {
    'row' => FlexDirection.row,
    'row-reverse' => FlexDirection.rowReverse,
    'column' => FlexDirection.column,
    'column-reverse' => FlexDirection.columnReverse,
    _ => null,
  };

  /// Parse CSS justify-content value
  static JustifyContent? parseJustifyContent(String value) => switch (value
      .toLowerCase()) {
    'flex-start' || 'start' => JustifyContent.start,
    'flex-end' || 'end' => JustifyContent.end,
    'center' => JustifyContent.center,
    'space-between' => JustifyContent.spaceBetween,
    'space-around' => JustifyContent.spaceAround,
    'space-evenly' => JustifyContent.spaceEvenly,
    _ => null,
  };

  /// Parse CSS align-items value
  static AlignItems? parseAlignItems(String value) => switch (value
      .toLowerCase()) {
    'flex-start' || 'start' => AlignItems.start,
    'flex-end' || 'end' => AlignItems.end,
    'center' => AlignItems.center,
    'stretch' => AlignItems.stretch,
    'baseline' => AlignItems.baseline,
    _ => null,
  };

  /// Parse CSS border-side value (e.g., '1px solid black')
  static BorderSide? parseBorderSide(String value) {
    final parts = value.split(' ');
    if (parts.length < 2) return null;

    final width = _sizeValueToPixels(parseSizeValue(parts[0]));
    if (width == null) return null;

    final style = parts[1].toLowerCase();
    final color = parts.length > 2 ? parseColor(parts[2]) : Colors.black;

    return BorderSide(
      width: width,
      color: color ?? Colors.black,
      style: style == 'dashed' ? BorderStyle.none : BorderStyle.solid,
    );
  }

  /// Parse inline style string into TagflowStyle
  static TagflowStyle? parseInlineStyle(
    String styleString, [
    TagflowTheme? theme,
  ]) {
    final styles = parseDeclarations(styleString);
    if (styles.isEmpty) return null;

    return TagflowStyle(
      // Text styles
      textStyle: _parseTextStyle(styles, theme),
      color: _parseStyleColor(styles, 'color', theme),
      textAlign: _parseStyleTextAlign(styles),

      // Layout styles
      padding: _parseStyleEdgeInsets(styles, 'padding'),
      margin: _parseStyleEdgeInsets(styles, 'margin'),
      alignment: _parseAlignment(styles),
      display: parseDisplay(styles['display'] ?? 'block'),

      // Box decoration styles
      backgroundColor: _parseStyleColor(styles, 'background-color', theme),
      borderRadius: _parseStyleBorderRadius(styles),
      border: _parseStyleBorder(styles),
      borderLeft: _parseStyleBorderSide(styles, 'border-left'),
      borderRight: _parseStyleBorderSide(styles, 'border-right'),
      borderTop: _parseStyleBorderSide(styles, 'border-top'),
      borderBottom: _parseStyleBorderSide(styles, 'border-bottom'),
      boxShadow: _parseStyleBoxShadow(styles),

      // Flexbox styles
      flexDirection:
          styles['flex-direction'] != null
              ? _parseFlexDirection(styles['flex-direction']!)
              : null,
      justifyContent: _parseStyleJustifyContent(styles),
      alignItems: _parseStyleAlignItems(styles),
      gap: _parseStyleSize(styles, 'gap'),

      // Size styles
      width: _parseStyleSize(styles, 'width'),
      height: _parseStyleSize(styles, 'height'),
      minWidth: _parseStyleSize(styles, 'min-width'),
      minHeight: _parseStyleSize(styles, 'min-height'),
      maxWidth: _parseStyleSize(styles, 'max-width'),
      maxHeight: _parseStyleSize(styles, 'max-height'),
      aspectRatio: _parseStyleDouble(styles, 'aspect-ratio'),

      // Visual effects
      opacity: _parseStyleDouble(styles, 'opacity'),
      overflow: styles['overflow'] == 'visible' ? Clip.none : Clip.hardEdge,
      transform: _parseStyleTransform(styles),
      boxFit: _parseStyleBoxFit(styles),
      cursor: _parseStyleCursor(styles),
    );
  }

  // Helper methods for cleaner inline style parsing
  static Color? _parseStyleColor(
    Map<String, String> styles,
    String key,
    TagflowTheme? theme,
  ) =>
      styles[key] != null ? parseColor(styles[key]!, theme?.namedColors) : null;

  static EdgeInsets? _parseStyleEdgeInsets(
    Map<String, String> styles,
    String key,
  ) => styles[key] != null ? parseEdgeInsets(styles[key]!) : null;

  static TextAlign? _parseStyleTextAlign(Map<String, String> styles) =>
      styles['text-align'] != null
          ? parseTextAlign(styles['text-align']!)
          : null;

  static BorderRadius? _parseStyleBorderRadius(Map<String, String> styles) =>
      styles['border-radius'] != null
          ? parseBorderRadius(styles['border-radius']!)
          : null;

  static Border? _parseStyleBorder(Map<String, String> styles) =>
      styles['border'] != null ? parseBorder(styles['border']!) : null;

  static BorderSide? _parseStyleBorderSide(
    Map<String, String> styles,
    String key,
  ) => styles[key] != null ? parseBorderSide(styles[key]!) : null;

  static List<BoxShadow>? _parseStyleBoxShadow(Map<String, String> styles) =>
      styles['box-shadow'] != null
          ? parseBoxShadow(styles['box-shadow']!)
          : null;

  static MainAxisAlignment? _parseStyleJustifyContent(
    Map<String, String> styles,
  ) =>
      styles['justify-content'] != null
          ? parseJustifyContent(
            styles['justify-content']!,
          )?.toMainAxisAlignment()
          : null;

  static CrossAxisAlignment? _parseStyleAlignItems(
    Map<String, String> styles,
  ) =>
      styles['align-items'] != null
          ? parseAlignItems(styles['align-items']!)?.toCrossAxisAlignment()
          : null;

  static SizeValue? _parseStyleSize(Map<String, String> styles, String key) =>
      styles[key] != null ? parseSizeValue(styles[key]!) : null;

  static double? _parseStyleDouble(Map<String, String> styles, String key) =>
      styles[key] != null ? double.tryParse(styles[key]!) : null;

  static Matrix4? _parseStyleTransform(Map<String, String> styles) =>
      styles['transform'] != null ? parseTransform(styles['transform']!) : null;

  static BoxFit? _parseStyleBoxFit(Map<String, String> styles) =>
      styles['object-fit'] != null ? parseBoxFit(styles['object-fit']!) : null;

  static MouseCursor? _parseStyleCursor(Map<String, String> styles) =>
      styles['cursor'] != null ? _parseCursor(styles['cursor']!) : null;

  /// Parse CSS declarations into a map
  static Map<String, String> parseDeclarations(String styleString) {
    final result = <String, String>{};
    final declarations = styleString.split(';');

    for (var i = 0; i < declarations.length; i++) {
      final declaration = declarations[i].trim();
      if (declaration.isEmpty) continue;

      final colonIndex = declaration.indexOf(':');
      if (colonIndex > 0 && colonIndex < declaration.length - 1) {
        final key = declaration.substring(0, colonIndex).trim();
        final value = declaration.substring(colonIndex + 1).trim();
        result[key] = value;
      }
    }

    return result;
  }

  /// Parse text-related styles into TextStyle
  static TextStyle? _parseTextStyle(
    Map<String, String> styles,
    TagflowTheme? theme,
  ) {
    return TextStyle(
      color:
          styles['color'] != null
              ? parseColor(styles['color']!, theme?.namedColors)
              : null,
      fontSize:
          styles['font-size'] != null ? parseSize(styles['font-size']!) : null,
      fontWeight:
          styles['font-weight'] != null
              ? parseFontWeight(styles['font-weight']!)
              : null,
      fontStyle:
          styles['font-style'] != null
              ? parseFontStyle(styles['font-style']!)
              : null,
      decoration:
          styles['text-decoration'] != null
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

  /// Parse cursor
  static MouseCursor? _parseCursor(String value) {
    return switch (value) {
      'pointer' => SystemMouseCursors.click,
      'text' => SystemMouseCursors.text,
      'none' => SystemMouseCursors.none,
      'help' => SystemMouseCursors.help,
      'wait' => SystemMouseCursors.wait,
      'move' => SystemMouseCursors.move,
      'not-allowed' => SystemMouseCursors.forbidden,
      _ => null,
    };
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
