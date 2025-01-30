import 'package:flutter/material.dart' show Colors;
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

  /// Parse a CSS size value into a SizeValue
  /// object that can handle percentage and viewport units
  static SizeValue? parseSizeValue(
    String value0, [
    double remSize = _defaultRemSize,
  ]) {
    final value = value0.trim().toLowerCase();

    // Handle percentage values
    if (value.endsWith('%')) {
      final number = double.tryParse(value.replaceAll('%', ''));
      return number != null ? SizeValue(number, SizeUnit.percentage) : null;
    }

    // Handle rem values
    if (value.endsWith('rem') || value.endsWith('em')) {
      final number =
          double.tryParse(value.replaceAll('rem', '').replaceAll('em', ''));
      return number != null ? SizeValue(number, SizeUnit.rem) : null;
    }

    // Handle viewport height
    if (value.endsWith('vh')) {
      final number = double.tryParse(value.replaceAll('vh', ''));
      return number != null ? SizeValue(number, SizeUnit.vh) : null;
    }

    // Handle viewport width
    if (value.endsWith('vw')) {
      final number = double.tryParse(value.replaceAll('vw', ''));
      return number != null ? SizeValue(number, SizeUnit.vw) : null;
    }

    // Handle pixel values or raw numbers (default to pixels)
    if (value.endsWith('px')) {
      final number = double.tryParse(value.replaceAll('px', ''));
      return number != null ? SizeValue(number) : null;
    }

    if (value.endsWith('pt')) {
      final number = double.tryParse(value.replaceAll('pt', ''));
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

    final sizeValue = parseSizeValue(parts[0]);
    if (sizeValue == null) return null;

    final style = parts[1].toLowerCase();
    final color = parts.length > 2 ? parseColor(parts[2]) : Colors.black;

    // For border width, we can only use absolute values
    double? width;
    switch (sizeValue.unit) {
      case SizeUnit.pt:
      case SizeUnit.px:
        width = sizeValue.value;
      case SizeUnit.rem:
        width = sizeValue.value * _defaultRemSize;
      case SizeUnit.percentage:
      case SizeUnit.vh:
      case SizeUnit.vw:
        return null;
    }

    switch (style) {
      case 'solid':
        return Border.all(
          width: width,
          color: color ?? Colors.black,
        );
      case 'none':
        return null;
      default:
        return null;
    }
  }

  /// Parse CSS box-shadow value
  static List<BoxShadow>? parseBoxShadow(String value) {
    final shadows = <BoxShadow>[];
    // Split on comma that's not inside parentheses
    final shadowStrings = value.split(RegExp(r',(?![^(]*\))'));

    for (final shadowString in shadowStrings) {
      final parts = shadowString.trim().split(' ');
      if (parts.length < 4) continue;

      try {
        final xValue = parseSizeValue(parts[0]);
        final yValue = parseSizeValue(parts[1]);
        final blurValue = parseSizeValue(parts[2]);
        final spreadValue = parts.length > 3
            ? parseSizeValue(parts[3]) ?? const SizeValue(0)
            : const SizeValue(0);

        // For box shadow, we can only use absolute values
        double? x;
        double? y;
        double? blur;
        double? spread;

        if (xValue != null) {
          if (xValue.unit == SizeUnit.px) {
            x = xValue.value;
          } else if (xValue.unit == SizeUnit.rem) {
            x = xValue.value * _defaultRemSize;
          }
        }

        if (yValue != null) {
          if (yValue.unit == SizeUnit.px) {
            y = yValue.value;
          } else if (yValue.unit == SizeUnit.rem) {
            y = yValue.value * _defaultRemSize;
          }
        }

        if (blurValue != null) {
          if (blurValue.unit == SizeUnit.px) {
            blur = blurValue.value;
          } else if (blurValue.unit == SizeUnit.rem) {
            blur = blurValue.value * _defaultRemSize;
          }
        }

        if (spreadValue.unit == SizeUnit.px) {
          spread = spreadValue.value;
        } else if (spreadValue.unit == SizeUnit.rem) {
          spread = spreadValue.value * _defaultRemSize;
        }

        if (x == null || y == null || blur == null || spread == null) {
          continue;
        }

        final colorStr = parts
                .any((part) => RegExp(r'rgba?\(|#').hasMatch(part))
            ? parts.firstWhere((part) => RegExp(r'rgba?\(|#').hasMatch(part))
            : 'rgba(0,0,0,0.2)';
        final color = parseColor(colorStr);

        shadows.add(
          BoxShadow(
            // ignore: deprecated_member_use
            color: color ?? Colors.black.withOpacity(0.2),
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

  /// Parse CSS border-side value (e.g., '1px solid black')
  static BorderSide? parseBorderSide(String value) {
    final parts = value.split(' ');
    if (parts.length < 2) return null;

    final sizeValue = parseSizeValue(parts[0]);
    if (sizeValue == null) return null;

    final style = parts[1].toLowerCase();
    final color = parts.length > 2 ? parseColor(parts[2]) : Colors.black;

    // For border width, we can only use absolute values
    double? width;
    switch (sizeValue.unit) {
      case SizeUnit.px:
      case SizeUnit.pt:
        width = sizeValue.value;
      case SizeUnit.rem:
        width = sizeValue.value * _defaultRemSize;
      case SizeUnit.percentage:
      case SizeUnit.vh:
      case SizeUnit.vw:
        return null;
    }

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
      border: styles['border'] != null ? parseBorder(styles['border']!) : null,
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
      gap: styles['gap'] != null ? parseSizeValue(styles['gap']!) : null,
      width: styles['width'] != null ? parseSizeValue(styles['width']!) : null,
      height:
          styles['height'] != null ? parseSizeValue(styles['height']!) : null,
      minWidth: styles['min-width'] != null
          ? parseSizeValue(styles['min-width']!)
          : null,
      minHeight: styles['min-height'] != null
          ? parseSizeValue(styles['min-height']!)
          : null,
      maxWidth: styles['max-width'] != null
          ? parseSizeValue(styles['max-width']!)
          : null,
      maxHeight: styles['max-height'] != null
          ? parseSizeValue(styles['max-height']!)
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
