import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// Utility class to parse CSS-like values into Flutter values
class StyleParser {
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
      if (hex.length != 8 || !RegExp(r'^[0-9a-f]{8}$').hasMatch(hex)) {
        return null;
      }
      final intValue = int.tryParse(hex, radix: 16);
      return intValue != null ? Color(intValue) : null;
    }

    // Handle rgb/rgba
    final rgbMatch = RegExp(r'rgba?\((.*?)\)').firstMatch(value);
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

  /// Parse a CSS size value with optional unit
  static double? parseSize(String value0, [double remSize = _defaultRemSize]) {
    final value = value0.trim().toLowerCase();

    // Handle percentage values
    // TODO(devaryakjha): Fix percentage values
    if (value.endsWith('%')) {
      // final number = double.tryParse(value.replaceAll('%', ''));
      // return number != null ? number / 100 : null;

      // temporary fix
      return null;
    }

    // Handle various units
    final units = {
      'px': 1.0,
      'rem': remSize,
      'em': remSize,
      'pt': 4 / 3, // 1pt = 1.333333px (rounded for precision)
      'vh': 1.0, // TODO(devaryakjha): Implement viewport relative units
      'vw': 1.0,
    };

    for (final unit in units.entries) {
      if (value.endsWith(unit.key)) {
        final number = double.tryParse(value.replaceAll(unit.key, ''));
        // Only round non-pixel values to avoid precision issues
        return number != null
            ? (unit.key == 'px'
                ? number
                : (number * unit.value).roundToDouble())
            : null;
      }
    }

    // Raw numbers without units are not valid CSS
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
    final parts = value.split(' ').map((s) {
      // Handle special case for '0'
      if (s == '0') return null;
      return parseSize(s);
    }).toList();

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
    // Handle special case for '0'
    if (value == '0') return null;
    final size = parseSize(value);
    return size != null ? BorderRadius.circular(size) : null;
  }

  /// Parse CSS border
  static BorderSide? parseBorderSide(String value) {
    final parts = value.split(' ');
    if (parts.length < 2) return null;

    // Parse width without rounding
    final width = parts[0].endsWith('px')
        ? double.tryParse(parts[0].replaceAll('px', ''))
        : parseSize(parts[0]);
    final style = parts[1].toLowerCase();

    // For dashed style, use black as default color if not specified
    final color = style == 'dashed'
        ? (parts.length > 2 ? parseColor(parts[2]) : const Color(0xFF000000))
        : (parts.length > 2 ? parseColor(parts[2]) : parseColor(parts[1]));

    if (width == null && color == null) return null;

    return BorderSide(
      width: width ?? 0,
      color: color ?? const Color(0xFF000000),
      style: style == 'dashed' ? BorderStyle.none : BorderStyle.solid,
    );
  }

  /// Parse CSS box shadow
  static List<BoxShadow>? parseBoxShadow(String value) {
    final shadows = <BoxShadow>[];
    // Split on comma that's not inside parentheses
    final shadowStrings = value.split(RegExp(r',(?![^(]*\))'));

    for (final shadow in shadowStrings) {
      final parts = shadow.trim().split(' ');
      if (parts.length < 4) continue;

      try {
        final x = parseSize(parts[0]) ?? 0;
        final y = parseSize(parts[1]) ?? 0;
        final blur = parseSize(parts[2]) ?? 0;
        final spread = parts.length > 3 ? (parseSize(parts[3]) ?? 0) : 0.0;
        final colorStr = parts.length > 4 ? parts[4] : 'rgba(0,0,0,0.2)';
        final color = parseColor(colorStr);

        if (color == null) continue;

        shadows.add(
          BoxShadow(
            color: color,
            offset: Offset(x, y),
            blurRadius: blur,
            spreadRadius: spread,
          ),
        );
      } catch (_) {
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
      final match = RegExp(r'(\w+)\((.*?)\)').firstMatch(t);
      if (match == null) return null;

      final function = match.group(1)!.toLowerCase();
      final args =
          match.group(2)!.split(',').map((s) => parseSize(s.trim())).toList();

      if (args.any((arg) => arg == null)) return null;

      final values = args.map((a) => a!).toList();

      switch (function) {
        case 'translate':
          if (values.length >= 2) {
            transform.translate(
              values[0],
              values[1],
              values.length > 2 ? values[2] : 0,
            );
          } else {
            return null;
          }
        case 'scale':
          if (values.isNotEmpty) {
            transform.scale(
              values[0],
              values.length > 1 ? values[1] : values[0],
              values.length > 2 ? values[2] : 1,
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
  static Display parseDisplay(String value) => switch (value.toLowerCase()) {
        'block' => Display.block,
        'inline' => Display.inline,
        'flex' => Display.flex,
        'none' => Display.none,
        _ => Display.block,
      };

  /// Parse CSS flex-direction value
  static FlexDirection? parseFlexDirection(String value) =>
      switch (value.toLowerCase()) {
        'row' => FlexDirection.row,
        'row-reverse' => FlexDirection.rowReverse,
        'column' => FlexDirection.column,
        'column-reverse' => FlexDirection.columnReverse,
        _ => null,
      };

  /// Parse CSS justify-content value
  static JustifyContent? parseJustifyContent(String value) =>
      switch (value.toLowerCase()) {
        'flex-start' || 'start' => JustifyContent.start,
        'flex-end' || 'end' => JustifyContent.end,
        'center' => JustifyContent.center,
        'space-between' => JustifyContent.spaceBetween,
        'space-around' => JustifyContent.spaceAround,
        'space-evenly' => JustifyContent.spaceEvenly,
        _ => null,
      };

  /// Parse CSS align-items value
  static AlignItems? parseAlignItems(String value) =>
      switch (value.toLowerCase()) {
        'flex-start' || 'start' => AlignItems.start,
        'flex-end' || 'end' => AlignItems.end,
        'center' => AlignItems.center,
        'stretch' => AlignItems.stretch,
        'baseline' => AlignItems.baseline,
        _ => null,
      };

  /// Parse inline style string into TagflowStyle
  static TagflowStyle? parseInlineStyle(
    String styleString, [
    TagflowTheme? theme,
  ]) {
    final styles = _parseDeclarations(styleString);
    if (styles.isEmpty) return null;

    return TagflowStyle(
      textStyle: _parseTextStyle(styles, theme),
      padding: styles['padding'] != null
          ? parseEdgeInsets(styles['padding']!)
          : null,
      margin:
          styles['margin'] != null ? parseEdgeInsets(styles['margin']!) : null,
      backgroundColor: styles['background-color'] != null
          ? parseColor(styles['background-color']!, theme?.namedColors)
          : null,
      color: styles['color'] != null
          ? parseColor(styles['color']!, theme?.namedColors)
          : null,
      borderRadius: styles['border-radius'] != null
          ? parseBorderRadius(styles['border-radius']!)
          : null,
      border: styles['border'] != null
          ? Border.all(
              width: parseSize(styles['border-width'] ?? '1px') ?? 1,
              color: parseColor(
                    styles['border-color'] ?? 'currentColor',
                    theme?.namedColors,
                  ) ??
                  const Color(0xFF000000),
            )
          : null,
      borderLeft: styles['border-left'] != null
          ? parseBorderSide(styles['border-left']!)
          : null,
      borderRight: styles['border-right'] != null
          ? parseBorderSide(styles['border-right']!)
          : null,
      borderTop: styles['border-top'] != null
          ? parseBorderSide(styles['border-top']!)
          : null,
      borderBottom: styles['border-bottom'] != null
          ? parseBorderSide(styles['border-bottom']!)
          : null,
      boxShadow: styles['box-shadow'] != null
          ? parseBoxShadow(styles['box-shadow']!)
          : null,
      alignment: _parseAlignment(styles),
      textAlign: styles['text-align'] != null
          ? parseTextAlign(styles['text-align']!)
          : null,
      display: parseDisplay(styles['display'] ?? 'block'),
      flexDirection: styles['flex-direction'] != null
          ? _parseFlexDirection(styles['flex-direction']!)
          : null,
      justifyContent: styles['justify-content'] != null
          ? parseJustifyContent(styles['justify-content']!)
              ?.toMainAxisAlignment()
          : null,
      alignItems: styles['align-items'] != null
          ? parseAlignItems(styles['align-items']!)?.toCrossAxisAlignment()
          : null,
      gap: styles['gap'] != null ? parseSize(styles['gap']!) : null,
      width: styles['width'] != null ? parseSize(styles['width']!) : null,
      height: styles['height'] != null ? parseSize(styles['height']!) : null,
      minWidth:
          styles['min-width'] != null ? parseSize(styles['min-width']!) : null,
      minHeight: styles['min-height'] != null
          ? parseSize(styles['min-height']!)
          : null,
      maxWidth:
          styles['max-width'] != null ? parseSize(styles['max-width']!) : null,
      maxHeight: styles['max-height'] != null
          ? parseSize(styles['max-height']!)
          : null,
      aspectRatio: styles['aspect-ratio'] != null
          ? double.tryParse(styles['aspect-ratio']!)
          : null,
      opacity: styles['opacity'] != null
          ? double.tryParse(styles['opacity']!)
          : null,
      overflow: styles['overflow'] == 'visible' ? Clip.none : Clip.hardEdge,
      transform: styles['transform'] != null
          ? parseTransform(styles['transform']!)
          : null,
      boxFit: styles['object-fit'] != null
          ? parseBoxFit(styles['object-fit']!)
          : null,
      cursor: styles['cursor'] != null ? _parseCursor(styles['cursor']!) : null,
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
  static TextStyle? _parseTextStyle(
    Map<String, String> styles,
    TagflowTheme? theme,
  ) {
    return TextStyle(
      color: styles['color'] != null
          ? parseColor(styles['color']!, theme?.namedColors)
          : null,
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
