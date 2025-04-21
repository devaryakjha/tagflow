import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:tagflow/tagflow.dart';

/// A widget that wraps the child with selectable functionality.
class TagflowSelectableAdapter extends StatelessWidget {
  /// Creates a [TagflowSelectableAdapter] widget.
  const TagflowSelectableAdapter({
    required this.child,
    super.key,
    this.text,
    this.padding = 10.0,
    this.cursor = SystemMouseCursors.text,
  });

  /// The child widget to be wrapped with selection functionality.
  final Widget child;

  /// Text that can be copied from the child.
  final String? text;

  /// Padding around the selection highlight.
  /// Defaults to 10.0 pixels.
  final double padding;

  /// Mouse cursor to show when hovering.
  /// Defaults to [SystemMouseCursors.text].
  final MouseCursor cursor;

  @override
  Widget build(BuildContext context) {
    final registrar = SelectionContainer.maybeOf(context);
    final options = TagflowOptions.maybeOf(context);

    // Early return if selection is not enabled
    if (registrar == null || !(options?.selectable.enabled ?? false)) {
      return child;
    }

    return MouseRegion(
      cursor: cursor,
      child: _SelectableAdapter(
        registrar: registrar,
        text: text,
        padding: padding,
        child: child,
      ),
    );
  }
}

class _SelectableAdapter extends SingleChildRenderObjectWidget {
  const _SelectableAdapter({
    required this.registrar,
    required super.child,
    required this.padding,
    this.text,
  });

  final String? text;
  final SelectionRegistrar registrar;
  final double padding;

  @override
  _RenderSelectableAdapter createRenderObject(BuildContext context) {
    return _RenderSelectableAdapter(
      DefaultSelectionStyle.of(context).selectionColor!,
      registrar,
      text,
      padding,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSelectableAdapter renderObject,
  ) {
    renderObject
      ..selectionColor = DefaultSelectionStyle.of(context).selectionColor!
      ..registrar = registrar
      ..text = text
      ..padding = padding;
  }
}

class _RenderSelectableAdapter extends RenderProxyBox
    with Selectable, SelectionRegistrant {
  _RenderSelectableAdapter(
    Color selectionColor,
    SelectionRegistrar registrar,
    String? text,
    double padding,
  )   : _selectionColor = selectionColor,
        _padding = padding,
        _geometry = ValueNotifier<SelectionGeometry>(_noSelection) {
    this.registrar = registrar;
    _text = text;
    _geometry.addListener(markNeedsPaint);
  }

  static const SelectionGeometry _noSelection =
      SelectionGeometry(status: SelectionStatus.none, hasContent: true);

  final ValueNotifier<SelectionGeometry> _geometry;

  Color get selectionColor => _selectionColor;
  Color _selectionColor;
  set selectionColor(Color value) {
    if (_selectionColor == value) return;
    _selectionColor = value;
    markNeedsPaint();
  }

  String? _text;
  String? get text => _text;
  set text(String? value) {
    if (_text == value) return;
    _text = value;
    markNeedsPaint();
  }

  double get padding => _padding;
  double _padding;
  set padding(double value) {
    if (_padding == value) return;
    _padding = value;
    markNeedsPaint();
  }

  // Cache for selection rect
  Rect? _selectionRect;
  void _invalidateSelectionRect() => _selectionRect = null;

  Rect _getSelectionHighlightRect() {
    return _selectionRect ??= Rect.fromLTWH(
      0 - padding,
      0 - padding,
      size.width + padding * 2,
      size.height + padding * 2,
    );
  }

  @override
  void performLayout() {
    super.performLayout();
    _invalidateSelectionRect();
  }

  // Selection handling
  Offset? _start;
  Offset? _end;

  void _updateGeometry() {
    if (_start == null || _end == null) {
      _geometry.value = _noSelection;
      return;
    }

    final renderObjectRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final selectionRect = Rect.fromPoints(_start!, _end!);

    if (renderObjectRect.intersect(selectionRect).isEmpty) {
      _geometry.value = _noSelection;
      return;
    }

    final highlightRect = _getSelectionHighlightRect();
    final isReversed = _start!.dy > _end!.dy ||
        (_start!.dy == _end!.dy && _start!.dx > _end!.dx);

    final firstPoint = SelectionPoint(
      localPosition: highlightRect.bottomLeft,
      lineHeight: highlightRect.size.height,
      handleType: TextSelectionHandleType.left,
    );
    final secondPoint = SelectionPoint(
      localPosition: highlightRect.bottomRight,
      lineHeight: highlightRect.size.height,
      handleType: TextSelectionHandleType.right,
    );

    _geometry.value = SelectionGeometry(
      status: SelectionStatus.uncollapsed,
      hasContent: true,
      startSelectionPoint: isReversed ? secondPoint : firstPoint,
      endSelectionPoint: isReversed ? firstPoint : secondPoint,
      selectionRects: [highlightRect],
    );
  }

  // ValueListenable APIs
  @override
  void addListener(VoidCallback listener) => _geometry.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _geometry.removeListener(listener);

  @override
  SelectionGeometry get value => _geometry.value;

  // Selectable APIs
  @override
  List<Rect> get boundingBoxes => <Rect>[paintBounds];

  @override
  SelectionResult dispatchSelectionEvent(SelectionEvent event) {
    var result = SelectionResult.none;
    switch (event.type) {
      case SelectionEventType.startEdgeUpdate:
      case SelectionEventType.endEdgeUpdate:
        final renderObjectRect = Rect.fromLTWH(0, 0, size.width, size.height);
        final point =
            globalToLocal((event as SelectionEdgeUpdateEvent).globalPosition);
        final adjustedPoint =
            SelectionUtils.adjustDragOffset(renderObjectRect, point);
        if (event.type == SelectionEventType.startEdgeUpdate) {
          _start = adjustedPoint;
        } else {
          _end = adjustedPoint;
        }
        result = SelectionUtils.getResultBasedOnRect(renderObjectRect, point);
      case SelectionEventType.clear:
        _start = _end = null;
      case SelectionEventType.selectAll:
      case SelectionEventType.selectWord:
      case SelectionEventType.selectParagraph:
        _start = Offset.zero;
        _end = Offset.infinite;
      case SelectionEventType.granularlyExtendSelection:
        result =
            _handleGranularSelection(event as GranularlyExtendSelectionEvent);
      case SelectionEventType.directionallyExtendSelection:
        result = _handleDirectionalSelection(
          event as DirectionallyExtendSelectionEvent,
        );
    }
    _updateGeometry();
    return result;
  }

  SelectionResult _handleGranularSelection(
    GranularlyExtendSelectionEvent event,
  ) {
    var result = SelectionResult.end;
    if (_start == null || _end == null) {
      if (event.forward) {
        _start = _end = Offset.zero;
      } else {
        _start = _end = Offset.infinite;
      }
    }
    final newOffset = event.forward ? Offset.infinite : Offset.zero;
    if (event.isEnd) {
      if (newOffset == _end) {
        result =
            event.forward ? SelectionResult.next : SelectionResult.previous;
      }
      _end = newOffset;
    } else {
      if (newOffset == _start) {
        result =
            event.forward ? SelectionResult.next : SelectionResult.previous;
      }
      _start = newOffset;
    }
    return result;
  }

  SelectionResult _handleDirectionalSelection(
    DirectionallyExtendSelectionEvent event,
  ) {
    final horizontalBaseLine = globalToLocal(Offset(event.dx, 0)).dx;
    final Offset newOffset;
    final bool forward;

    switch (event.direction) {
      case SelectionExtendDirection.backward:
      case SelectionExtendDirection.previousLine:
        forward = false;
        if (_start == null || _end == null) {
          _start = _end = Offset.infinite;
        }
        newOffset = event.direction == SelectionExtendDirection.previousLine ||
                horizontalBaseLine < 0
            ? Offset.zero
            : Offset.infinite;
      case SelectionExtendDirection.nextLine:
      case SelectionExtendDirection.forward:
        forward = true;
        if (_start == null || _end == null) {
          _start = _end = Offset.zero;
        }
        newOffset = event.direction == SelectionExtendDirection.nextLine ||
                horizontalBaseLine > size.width
            ? Offset.infinite
            : Offset.zero;
    }

    if (event.isEnd) {
      if (newOffset == _end) {
        return forward ? SelectionResult.next : SelectionResult.previous;
      }
      _end = newOffset;
    } else {
      if (newOffset == _start) {
        return forward ? SelectionResult.next : SelectionResult.previous;
      }
      _start = newOffset;
    }
    return SelectionResult.end;
  }

  @override
  SelectedContent? getSelectedContent() {
    return value.hasSelection ? SelectedContent(plainText: text ?? '') : null;
  }

  LayerLink? _startHandle;
  LayerLink? _endHandle;

  @override
  void pushHandleLayers(LayerLink? startHandle, LayerLink? endHandle) {
    if (_startHandle == startHandle && _endHandle == endHandle) return;
    _startHandle = startHandle;
    _endHandle = endHandle;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    if (!_geometry.value.hasSelection) return;

    // Draw selection highlight
    final selectionPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _selectionColor;
    context.canvas
        .drawRect(_getSelectionHighlightRect().shift(offset), selectionPaint);

    // Push handle layers
    if (_startHandle != null) {
      context.pushLayer(
        LeaderLayer(
          link: _startHandle!,
          offset: offset + value.startSelectionPoint!.localPosition,
        ),
        (_, __) {},
        Offset.zero,
      );
    }
    if (_endHandle != null) {
      context.pushLayer(
        LeaderLayer(
          link: _endHandle!,
          offset: offset + value.endSelectionPoint!.localPosition,
        ),
        (_, __) {},
        Offset.zero,
      );
    }
  }

  @override
  void dispose() {
    _geometry.dispose();
    super.dispose();
  }

  @override
  int get contentLength => 1;

  @override
  SelectedContentRange? getSelection() {
    if (!value.hasSelection) {
      return null;
    }
    return const SelectedContentRange(startOffset: 0, endOffset: 1);
  }
}
