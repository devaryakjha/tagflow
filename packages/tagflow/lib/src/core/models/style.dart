import 'package:flutter/widgets.dart';

/// Defines the display type of an element
enum Display {
  /// Block elements start on a new line and take up the full width
  block,

  /// Inline elements only take up as much width as necessary
  inline,

  /// Flex container
  flex,

  /// Hidden elements are not rendered
  none,
}

/// Defines the flex direction of a flex container
enum FlexDirection {
  /// Items are placed from left to right
  row,

  /// Items are placed from right to left
  rowReverse,

  /// Items are placed from top to bottom
  column,

  /// Items are placed from bottom to top
  columnReverse;

  /// Convert to Flutter's [Axis]
  Axis get axis => switch (this) {
        row || rowReverse => Axis.horizontal,
        column || columnReverse => Axis.vertical,
      };

  /// Whether the direction is reversed
  bool get isReversed => this == rowReverse || this == columnReverse;
}

/// Defines how flex items wrap
enum FlexWrap {
  /// Items are laid out in a single line
  nowrap,

  /// Items wrap around to additional lines
  wrap,

  /// Items wrap around to additional lines in reverse
  wrapReverse,
}

/// Defines how flex items are aligned along the cross axis
enum AlignContent {
  /// Lines are packed toward the start of the container
  start,

  /// Lines are packed toward the end of the container
  end,

  /// Lines are packed toward the center of the container
  center,

  /// Lines are evenly distributed with equal space around each line
  spaceBetween,

  /// Lines are evenly distributed with equal space before and after each line
  spaceAround,

  /// Lines are evenly distributed with equal space between each line
  spaceEvenly,

  /// Lines stretch to take up the remaining space
  stretch,
}

/// Defines how flex items are aligned along the main axis
enum JustifyContent {
  /// Items are packed toward the start
  start,

  /// Items are packed toward the end
  end,

  /// Items are centered along the line
  center,

  /// Items are evenly distributed with equal space between each item
  spaceBetween,

  /// Items are evenly distributed with equal space around each item
  spaceAround,

  /// Items are evenly distributed with equal space between each item
  spaceEvenly,
}

/// Defines how flex items are aligned along the cross axis
enum AlignItems {
  /// Items are aligned at the start
  start,

  /// Items are aligned at the end
  end,

  /// Items are centered
  center,

  /// Items are stretched to fill the container
  stretch,

  /// Items are aligned at their baselines
  baseline,
}
