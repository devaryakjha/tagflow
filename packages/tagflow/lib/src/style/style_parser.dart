// lib/src/style/style_parser.dart
import 'package:flutter/widgets.dart';

/// Utility class to parse CSS-like values into Flutter values
class StyleParser {
  /// Parse a CSS font-size value
  static double? parseFontSize(String value) {
    if (value.endsWith('px')) {
      return double.tryParse(value.replaceAll('px', ''));
    }
    if (value.endsWith('rem')) {
      final size = double.tryParse(value.replaceAll('rem', ''));
      return size != null ? size * 16 : null; // 1rem = 16px
    }
    return double.tryParse(value);
  }

  /// Parse a CSS font-weight value
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

  /// Parse a CSS color value
  static Color? parseColor(String value) {
    if (value.startsWith('#')) {
      var colorValue = value.replaceAll('#', '');
      if (colorValue.length == 3) {
        colorValue = colorValue.split('').map((e) => '$e$e').join();
      }
      final intValue = int.tryParse(colorValue, radix: 16);
      return intValue != null ? Color(0xFF000000 | intValue) : null;
    }

    // handle rgb and rgba colors, where the last value is optional,
    // but if present it can be a number between 0 and 1.
    // e.g. rgba(255, 0, 0, 0.5)
    if (value.startsWith('rgb')) {
      // Remove rgb/rgba prefix and parentheses, then split by comma
      final rawValues = value
          .replaceAll(RegExp(r'rgba?\(|\)'), '')
          .split(',')
          .map((s) => s.trim());

      try {
        final values = rawValues.take(3).map(int.parse).toList();
        if (values.length == 3) {
          // Handle alpha if present (rgba)
          if (rawValues.length > 3) {
            final alpha = double.parse(rawValues.elementAt(3));
            final alphaInt = (alpha * 255).round();
            return Color.fromARGB(alphaInt, values[0], values[1], values[2]);
          }
          return Color.fromRGBO(values[0], values[1], values[2], 1);
        }
      } catch (e) {
        return null; // Return null if parsing fails
      }
    }

    // Add named colors if needed
    return null;
  }

  /// Parse a CSS size value (for margin, padding, etc)
  static EdgeInsets? parseEdgeInsets(String value) {
    final parts = value.split(' ').map(parseSize).toList();

    return switch (parts.length) {
      1 when parts[0] != null => EdgeInsets.all(parts[0]!),
      2 when parts.every((e) => e != null) => EdgeInsets.symmetric(
          vertical: parts[0]!,
          horizontal: parts[1]!,
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

  /// Parse a CSS size value
  static double? parseSize(String value, [double remSize = 16]) {
    if (value.endsWith('rem')) {
      final size = double.tryParse(value.replaceAll('rem', ''));
      return size != null ? size * remSize : null; // 1rem = remSize
    }

    if (value.endsWith('px')) {
      return double.tryParse(value.replaceAll('px', ''));
    }
    return double.tryParse(value);
  }

  /// Parse a CSS font-style value
  static FontStyle? parseFontStyle(String value) {
    return switch (value.toLowerCase()) {
      'italic' => FontStyle.italic,
      'normal' => FontStyle.normal,
      _ => null,
    };
  }

  /// Parse CSS text-decoration value
  static TextDecoration? parseTextDecoration(String value) {
    return switch (value.toLowerCase()) {
      'underline' => TextDecoration.underline,
      'line-through' => TextDecoration.lineThrough,
      'overline' => TextDecoration.overline,
      'none' => TextDecoration.none,
      _ => null,
    };
  }

  /// Parse text-align value
  static TextAlign? parseTextAlign(String value) {
    return switch (value.toLowerCase()) {
      'left' => TextAlign.left,
      'right' => TextAlign.right,
      'center' => TextAlign.center,
      'justify' => TextAlign.justify,
      _ => null,
    };
  }

  /// Parse object-fit value
  static BoxFit? parseBoxFit(String value) {
    return switch (value.toLowerCase()) {
      'contain' => BoxFit.contain,
      'cover' => BoxFit.cover,
      'fill' => BoxFit.fill,
      'none' => BoxFit.none,
      'scale-down' => BoxFit.scaleDown,
      'scale-down-x' => BoxFit.scaleDown,
      'scale-down-y' => BoxFit.scaleDown,
      _ => null,
    };
  }
}
