import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class NoToolBar extends MaterialTextSelectionControls {
  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    return Container(height: 0, width: 0);
  }
}
    /*
class CustomToolBar extends MaterialTextSelectionControls {
  static const double _kToolbarContentDistanceBelow = 20.0;
  static const double _kToolbarContentDistance = 8.0;

  @override
  Widget buildToolbar(
    BuildContext context,
    Rect globalEditableRegion,
    double textLineHeight,
    Offset selectionMidpoint,
    List<TextSelectionPoint> endpoints,
    TextSelectionDelegate delegate,
    ClipboardStatusNotifier clipboardStatus,
    Offset? lastSecondaryTapDownPosition,
  ) {
    final TextSelectionPoint startTextSelectionPoint = endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        endpoints.length > 1 ? endpoints[1] : endpoints[0];
    final Offset anchorAbove = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          startTextSelectionPoint.point.dy -
          textLineHeight -
          _kToolbarContentDistance,
    );
    final Offset anchorBelow = Offset(
      globalEditableRegion.left + selectionMidpoint.dx,
      globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      children: <Widget>[
        TextSelectionToolbarTextButton(
          padding: TextSelectionToolbarTextButton.getPadding(0, 1),
          onPressed: () {
            print('clicked');
          },
          child: const Text('Custom button'),
        ),
      ],
    );
    */

/*
}
*/
/*
// The label and callback for the available default text selection menu buttons.
class _TextSelectionToolbarItemData {
  const _TextSelectionToolbarItemData({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;
}

const double _kHandleSize = 22.0;
const double _kToolbarContentDistanceBelow = _kHandleSize - 2.0;
const double _kToolbarContentDistance = 8.0;

// The highest level toolbar widget, built directly by buildToolbar.
class _TextSelectionControlsToolbar extends StatefulWidget {
  const _TextSelectionControlsToolbar({
    Key? key,
    required this.clipboardStatus,
    required this.delegate,
    required this.endpoints,
    required this.globalEditableRegion,
    required this.handleCut,
    required this.handleCopy,
    required this.handlePaste,
    required this.handleSelectAll,
    required this.selectionMidpoint,
    required this.textLineHeight,
  }) : super(key: key);

  final ClipboardStatusNotifier clipboardStatus;
  final TextSelectionDelegate delegate;
  final List<TextSelectionPoint> endpoints;
  final Rect globalEditableRegion;
  final VoidCallback? handleCut;
  final VoidCallback? handleCopy;
  final VoidCallback? handlePaste;
  final VoidCallback? handleSelectAll;
  final Offset selectionMidpoint;
  final double textLineHeight;

  @override
  _TextSelectionControlsToolbarState createState() =>
      _TextSelectionControlsToolbarState();
}

class _TextSelectionControlsToolbarState
    extends State<_TextSelectionControlsToolbar> with TickerProviderStateMixin {
  void _onChangedClipboardStatus() {
    setState(() {
      // Inform the widget that the value of clipboardStatus has changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.clipboardStatus.addListener(_onChangedClipboardStatus);
    widget.clipboardStatus.update();
  }

  @override
  void didUpdateWidget(_TextSelectionControlsToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.clipboardStatus != oldWidget.clipboardStatus) {
      widget.clipboardStatus.addListener(_onChangedClipboardStatus);
      oldWidget.clipboardStatus.removeListener(_onChangedClipboardStatus);
    }
    widget.clipboardStatus.update();
  }

  @override
  void dispose() {
    super.dispose();
    // When used in an Overlay, it can happen that this is disposed after its
    // creator has already disposed _clipboardStatus.
    if (!widget.clipboardStatus.disposed) {
      widget.clipboardStatus.removeListener(_onChangedClipboardStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If there are no buttons to be shown, don't render anything.
    if (widget.handleCut == null &&
        widget.handleCopy == null &&
        widget.handlePaste == null &&
        widget.handleSelectAll == null) {
      return const SizedBox.shrink();
    }
    // If the paste button is desired, don't render anything until the state of
    // the clipboard is known, since it's used to determine if paste is shown.
    if (widget.handlePaste != null &&
        widget.clipboardStatus.value == ClipboardStatus.unknown) {
      return const SizedBox.shrink();
    }

    // Calculate the positioning of the menu. It is placed above the selection
    // if there is enough room, or otherwise below.
    final TextSelectionPoint startTextSelectionPoint = widget.endpoints[0];
    final TextSelectionPoint endTextSelectionPoint =
        widget.endpoints.length > 1 ? widget.endpoints[1] : widget.endpoints[0];
    final Offset anchorAbove = Offset(
      widget.globalEditableRegion.left + widget.selectionMidpoint.dx,
      widget.globalEditableRegion.top +
          startTextSelectionPoint.point.dy -
          widget.textLineHeight -
          _kToolbarContentDistance,
    );
    final Offset anchorBelow = Offset(
      widget.globalEditableRegion.left + widget.selectionMidpoint.dx,
      widget.globalEditableRegion.top +
          endTextSelectionPoint.point.dy +
          _kToolbarContentDistanceBelow,
    );

    // Determine which buttons will appear so that the order and total number is
    // known. A button's position in the menu can slightly affect its
    // appearance.
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final List<_TextSelectionToolbarItemData> itemDatas =
        <_TextSelectionToolbarItemData>[
      if (widget.handleCut != null)
        _TextSelectionToolbarItemData(
          label: localizations.cutButtonLabel,
          onPressed: widget.handleCut!,
        ),
      if (widget.handleCopy != null)
        _TextSelectionToolbarItemData(
          label: localizations.copyButtonLabel,
          onPressed: widget.handleCopy!,
        ),
      if (widget.handlePaste != null &&
          widget.clipboardStatus.value == ClipboardStatus.pasteable)
        _TextSelectionToolbarItemData(
          label: localizations.pasteButtonLabel,
          onPressed: widget.handlePaste!,
        ),
      if (widget.handleSelectAll != null)
        _TextSelectionToolbarItemData(
          label: localizations.selectAllButtonLabel,
          onPressed: widget.handleSelectAll!,
        ),
    ];

    // If there is no option available, build an empty widget.
    if (itemDatas.isEmpty) {
      return const SizedBox(width: 0.0, height: 0.0);
    }

    return TextSelectionToolbar(
      anchorAbove: anchorAbove,
      anchorBelow: anchorBelow,
      children: itemDatas
          .asMap()
          .entries
          .map((MapEntry<int, _TextSelectionToolbarItemData> entry) {
        return TextSelectionToolbarTextButton(
          padding: TextSelectionToolbarTextButton.getPadding(
              entry.key, itemDatas.length),
          onPressed: entry.value.onPressed,
          child: Text(entry.value.label),
        );
      }).toList(),
    );
  }
}


















import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Minimal padding from all edges of the selection toolbar to all edges of the
// viewport.
const double _kToolbarScreenPadding = 8.0;
const double _kToolbarHeight = 44.0;

/// A fully-functional Material-style text selection toolbar.
///
/// Tries to position itself above [anchorAbove], but if it doesn't fit, then
/// it positions itself below [anchorBelow].
///
/// If any children don't fit in the menu, an overflow menu will automatically
/// be created.
///
/// See also:
///
///  * [TextSelectionControls.buildToolbar], where this is used by default to
///    build an Android-style toolbar.
///  * [CupertinoTextSelectionToolbar], which is similar, but builds an iOS-
///    style toolbar.
class CustomToolBar extends StatelessWidget {
  /// Creates an instance of TextSelectionToolbar.
  const CustomToolBar({
    Key? key,
    required this.anchorAbove,
    required this.anchorBelow,
    this.toolbarBuilder = _defaultToolbarBuilder,
    required this.children,
  })  : assert(children.length > 0),
        super(key: key);

  /// {@template flutter.material.TextSelectionToolbar.anchorAbove}
  /// The focal point above which the toolbar attempts to position itself.
  ///
  /// If there is not enough room above before reaching the top of the screen,
  /// then the toolbar will position itself below [anchorBelow].
  /// {@endtemplate}
  final Offset anchorAbove;

  /// {@template flutter.material.TextSelectionToolbar.anchorBelow}
  /// The focal point below which the toolbar attempts to position itself, if it
  /// doesn't fit above [anchorAbove].
  /// {@endtemplate}
  final Offset anchorBelow;

  /// {@template flutter.material.TextSelectionToolbar.children}
  /// The children that will be displayed in the text selection toolbar.
  ///
  /// Typically these are buttons.
  ///
  /// Must not be empty.
  /// {@endtemplate}
  ///
  /// See also:
  ///   * [TextSelectionToolbarTextButton], which builds a default Material-
  ///     style text selection toolbar text button.
  final List<Widget> children;

  /// {@template flutter.material.TextSelectionToolbar.toolbarBuilder}
  /// Builds the toolbar container.
  ///
  /// Useful for customizing the high-level background of the toolbar. The given
  /// child Widget will contain all of the [children].
  /// {@endtemplate}
  final ToolbarBuilder toolbarBuilder;

  // Build the default Android Material text selection menu toolbar.
  static Widget _defaultToolbarBuilder(BuildContext context, Widget child) {
    return _TextSelectionToolbarContainer(
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double paddingAbove =
        MediaQuery.of(context).padding.top + _kToolbarScreenPadding;
    final double availableHeight = anchorAbove.dy - paddingAbove;
    final bool fitsAbove = _kToolbarHeight <= availableHeight;
    final Offset localAdjustment = Offset(_kToolbarScreenPadding, paddingAbove);
    print(paddingAbove);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _kToolbarScreenPadding,
        paddingAbove,
        _kToolbarScreenPadding,
        _kToolbarScreenPadding,
      ),
      child: Stack(
        children: <Widget>[
          CustomSingleChildLayout(
            delegate: TextSelectionToolbarLayoutDelegate(
              anchorAbove: anchorAbove - localAdjustment,
              anchorBelow: anchorBelow - localAdjustment,
              fitsAbove: fitsAbove,
            ),
            child: _TextSelectionToolbarOverflowable(
              isAbove: fitsAbove,
              toolbarBuilder: toolbarBuilder,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// A toolbar containing the given children. If they overflow the width
// available, then the overflowing children will be displayed in an overflow
// menu.
class _TextSelectionToolbarOverflowable extends StatefulWidget {
  const _TextSelectionToolbarOverflowable({
    Key? key,
    required this.isAbove,
    required this.toolbarBuilder,
    required this.children,
  })  : assert(children.length > 0),
        super(key: key);

  final List<Widget> children;

  // When true, the toolbar fits above its anchor and will be positioned there.
  final bool isAbove;

  // Builds the toolbar that will be populated with the children and fit inside
  // of the layout that adjusts to overflow.
  final ToolbarBuilder toolbarBuilder;

  @override
  _TextSelectionToolbarOverflowableState createState() =>
      _TextSelectionToolbarOverflowableState();
}

class _TextSelectionToolbarOverflowableState
    extends State<_TextSelectionToolbarOverflowable>
    with TickerProviderStateMixin {
  // Whether or not the overflow menu is open. When it is closed, the menu
  // items that don't overflow are shown. When it is open, only the overflowing
  // menu items are shown.
  bool _overflowOpen = false;

  // The key for _TextSelectionToolbarTrailingEdgeAlign.
  UniqueKey _containerKey = UniqueKey();

  // Close the menu and reset layout calculations, as in when the menu has
  // changed and saved values are no longer relevant. This should be called in
  // setState or another context where a rebuild is happening.
  void _reset() {
    // Change _TextSelectionToolbarTrailingEdgeAlign's key when the menu changes in
    // order to cause it to rebuild. This lets it recalculate its
    // saved width for the new set of children, and it prevents AnimatedSize
    // from animating the size change.
    _containerKey = UniqueKey();
    // If the menu items change, make sure the overflow menu is closed. This
    // prevents getting into a broken state where _overflowOpen is true when
    // there are not enough children to cause overflow.
    _overflowOpen = false;
  }

  @override
  void didUpdateWidget(_TextSelectionToolbarOverflowable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the children are changing at all, the current page should be reset.
    if (!listEquals(widget.children, oldWidget.children)) {
      _reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);

    return _TextSelectionToolbarTrailingEdgeAlign(
      key: _containerKey,
      overflowOpen: _overflowOpen,
      textDirection: Directionality.of(context),
      child: AnimatedSize(
        // This duration was eyeballed on a Pixel 2 emulator running Android
        // API 28.
        duration: const Duration(milliseconds: 140),
        child: widget.toolbarBuilder(
            context,
            _TextSelectionToolbarItemsLayout(
              isAbove: widget.isAbove,
              overflowOpen: _overflowOpen,
              children: <Widget>[
                // TODO(justinmc): This overflow button should have its own slot in
                // _TextSelectionToolbarItemsLayout separate from children, similar
                // to how it's done in Cupertino's text selection menu.
                // https://github.com/flutter/flutter/issues/69908
                // The navButton that shows and hides the overflow menu is the
                // first child.
                _TextSelectionToolbarOverflowButton(
                  icon:
                      Icon(_overflowOpen ? Icons.arrow_back : Icons.more_vert),
                  onPressed: () {
                    setState(() {
                      _overflowOpen = !_overflowOpen;
                    });
                  },
                  tooltip: _overflowOpen
                      ? localizations.backButtonTooltip
                      : localizations.moreButtonTooltip,
                ),
                ...widget.children,
              ],
            )),
      ),
    );
  }
}

// When the overflow menu is open, it tries to align its trailing edge to the
// trailing edge of the closed menu. This widget handles this effect by
// measuring and maintaining the width of the closed menu and aligning the child
// to that side.
class _TextSelectionToolbarTrailingEdgeAlign
    extends SingleChildRenderObjectWidget {
  const _TextSelectionToolbarTrailingEdgeAlign({
    Key? key,
    required Widget child,
    required this.overflowOpen,
    required this.textDirection,
  })  : assert(child != null),
        assert(overflowOpen != null),
        super(key: key, child: child);

  final bool overflowOpen;
  final TextDirection textDirection;

  @override
  _TextSelectionToolbarTrailingEdgeAlignRenderBox createRenderObject(
      BuildContext context) {
    return _TextSelectionToolbarTrailingEdgeAlignRenderBox(
      overflowOpen: overflowOpen,
      textDirection: textDirection,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      _TextSelectionToolbarTrailingEdgeAlignRenderBox renderObject) {
    renderObject
      ..overflowOpen = overflowOpen
      ..textDirection = textDirection;
  }
}

class _TextSelectionToolbarTrailingEdgeAlignRenderBox extends RenderProxyBox {
  _TextSelectionToolbarTrailingEdgeAlignRenderBox({
    required bool overflowOpen,
    required TextDirection textDirection,
  })  : _textDirection = textDirection,
        _overflowOpen = overflowOpen,
        super();

  // The width of the menu when it was closed. This is used to achieve the
  // behavior where the open menu aligns its trailing edge to the closed menu's
  // trailing edge.
  double? _closedWidth;

  bool _overflowOpen;
  bool get overflowOpen => _overflowOpen;
  set overflowOpen(bool value) {
    if (value == overflowOpen) {
      return;
    }
    _overflowOpen = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (value == textDirection) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    child!.layout(constraints.loosen(), parentUsesSize: true);

    // Save the width when the menu is closed. If the menu changes, this width
    // is invalid, so it's important that this RenderBox be recreated in that
    // case. Currently, this is achieved by providing a new key to
    // _TextSelectionToolbarTrailingEdgeAlign.
    if (!overflowOpen && _closedWidth == null) {
      _closedWidth = child!.size.width;
    }

    size = constraints.constrain(Size(
      // If the open menu is wider than the closed menu, just use its own width
      // and don't worry about aligning the trailing edges.
      // _closedWidth is used even when the menu is closed to allow it to
      // animate its size while keeping the same edge alignment.
      _closedWidth == null || child!.size.width > _closedWidth!
          ? child!.size.width
          : _closedWidth!,
      child!.size.height,
    ));

    // Set the offset in the parent data such that the child will be aligned to
    // the trailing edge, depending on the text direction.
    final ToolbarItemsParentData childParentData =
        child!.parentData! as ToolbarItemsParentData;
    childParentData.offset = Offset(
      textDirection == TextDirection.rtl ? 0.0 : size.width - child!.size.width,
      0.0,
    );
  }

  // Paint at the offset set in the parent data.
  @override
  void paint(PaintingContext context, Offset offset) {
    final ToolbarItemsParentData childParentData =
        child!.parentData! as ToolbarItemsParentData;
    context.paintChild(child!, childParentData.offset + offset);
  }

  // Include the parent data offset in the hit test.
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    final ToolbarItemsParentData childParentData =
        child!.parentData! as ToolbarItemsParentData;
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child!.hitTest(result, position: transformed);
      },
    );
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ToolbarItemsParentData) {
      child.parentData = ToolbarItemsParentData();
    }
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    final ToolbarItemsParentData childParentData =
        child.parentData! as ToolbarItemsParentData;
    transform.translate(childParentData.offset.dx, childParentData.offset.dy);
    super.applyPaintTransform(child, transform);
  }
}

// Renders the menu items in the correct positions in the menu and its overflow
// submenu based on calculating which item would first overflow.
class _TextSelectionToolbarItemsLayout extends MultiChildRenderObjectWidget {
  _TextSelectionToolbarItemsLayout({
    Key? key,
    required this.isAbove,
    required this.overflowOpen,
    required List<Widget> children,
  })  : assert(children != null),
        assert(isAbove != null),
        assert(overflowOpen != null),
        super(key: key, children: children);

  final bool isAbove;
  final bool overflowOpen;

  @override
  _RenderTextSelectionToolbarItemsLayout createRenderObject(
      BuildContext context) {
    return _RenderTextSelectionToolbarItemsLayout(
      isAbove: isAbove,
      overflowOpen: overflowOpen,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      _RenderTextSelectionToolbarItemsLayout renderObject) {
    renderObject
      ..isAbove = isAbove
      ..overflowOpen = overflowOpen;
  }

  @override
  _TextSelectionToolbarItemsLayoutElement createElement() =>
      _TextSelectionToolbarItemsLayoutElement(this);
}

class _TextSelectionToolbarItemsLayoutElement
    extends MultiChildRenderObjectElement {
  _TextSelectionToolbarItemsLayoutElement(
    MultiChildRenderObjectWidget widget,
  ) : super(widget);

  static bool _shouldPaint(Element child) {
    return (child.renderObject!.parentData! as ToolbarItemsParentData)
        .shouldPaint;
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    children.where(_shouldPaint).forEach(visitor);
  }
}

class _RenderTextSelectionToolbarItemsLayout extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, ToolbarItemsParentData> {
  _RenderTextSelectionToolbarItemsLayout({
    required bool isAbove,
    required bool overflowOpen,
  })  : assert(overflowOpen != null),
        assert(isAbove != null),
        _isAbove = isAbove,
        _overflowOpen = overflowOpen,
        super();

  // The index of the last item that doesn't overflow.
  int _lastIndexThatFits = -1;

  bool _isAbove;
  bool get isAbove => _isAbove;
  set isAbove(bool value) {
    if (value == isAbove) {
      return;
    }
    _isAbove = value;
    markNeedsLayout();
  }

  bool _overflowOpen;
  bool get overflowOpen => _overflowOpen;
  set overflowOpen(bool value) {
    if (value == overflowOpen) {
      return;
    }
    _overflowOpen = value;
    markNeedsLayout();
  }

  // Layout the necessary children, and figure out where the children first
  // overflow, if at all.
  void _layoutChildren() {
    // When overflow is not open, the toolbar is always a specific height.
    final BoxConstraints sizedConstraints = _overflowOpen
        ? constraints
        : BoxConstraints.loose(Size(
            constraints.maxWidth,
            _kToolbarHeight,
          ));

    int i = -1;
    double width = 0.0;
    visitChildren((RenderObject renderObjectChild) {
      i++;

      // No need to layout children inside the overflow menu when it's closed.
      // The opposite is not true. It is necessary to layout the children that
      // don't overflow when the overflow menu is open in order to calculate
      // _lastIndexThatFits.
      if (_lastIndexThatFits != -1 && !overflowOpen) {
        return;
      }

      final RenderBox child = renderObjectChild as RenderBox;
      child.layout(sizedConstraints.loosen(), parentUsesSize: true);
      width += child.size.width;

      if (width > sizedConstraints.maxWidth && _lastIndexThatFits == -1) {
        _lastIndexThatFits = i - 1;
      }
    });

    // If the last child overflows, but only because of the width of the
    // overflow button, then just show it and hide the overflow button.
    final RenderBox navButton = firstChild!;
    if (_lastIndexThatFits != -1 &&
        _lastIndexThatFits == childCount - 2 &&
        width - navButton.size.width <= sizedConstraints.maxWidth) {
      _lastIndexThatFits = -1;
    }
  }

  // Returns true when the child should be painted, false otherwise.
  bool _shouldPaintChild(RenderObject renderObjectChild, int index) {
    // Paint the navButton when there is overflow.
    if (renderObjectChild == firstChild) {
      return _lastIndexThatFits != -1;
    }

    // If there is no overflow, all children besides the navButton are painted.
    if (_lastIndexThatFits == -1) {
      return true;
    }

    // When there is overflow, paint if the child is in the part of the menu
    // that is currently open. Overflowing children are painted when the
    // overflow menu is open, and the children that fit are painted when the
    // overflow menu is closed.
    return (index > _lastIndexThatFits) == overflowOpen;
  }

  // Decide which children will be painted, set their shouldPaint, and set the
  // offset that painted children will be placed at.
  void _placeChildren() {
    int i = -1;
    Size nextSize = Size.zero;
    double fitWidth = 0.0;
    final RenderBox navButton = firstChild!;
    double overflowHeight =
        overflowOpen && !isAbove ? navButton.size.height : 0.0;
    visitChildren((RenderObject renderObjectChild) {
      i++;

      final RenderBox child = renderObjectChild as RenderBox;
      final ToolbarItemsParentData childParentData =
          child.parentData! as ToolbarItemsParentData;

      // Handle placing the navigation button after iterating all children.
      if (renderObjectChild == navButton) {
        return;
      }

      // There is no need to place children that won't be painted.
      if (!_shouldPaintChild(renderObjectChild, i)) {
        childParentData.shouldPaint = false;
        return;
      }
      childParentData.shouldPaint = true;

      if (!overflowOpen) {
        childParentData.offset = Offset(fitWidth, 0.0);
        fitWidth += child.size.width;
        nextSize = Size(
          fitWidth,
          math.max(child.size.height, nextSize.height),
        );
      } else {
        childParentData.offset = Offset(0.0, overflowHeight);
        overflowHeight += child.size.height;
        nextSize = Size(
          math.max(child.size.width, nextSize.width),
          overflowHeight,
        );
      }
    });

    // Place the navigation button if needed.
    final ToolbarItemsParentData navButtonParentData =
        navButton.parentData! as ToolbarItemsParentData;
    if (_shouldPaintChild(firstChild!, 0)) {
      navButtonParentData.shouldPaint = true;
      if (overflowOpen) {
        navButtonParentData.offset =
            isAbove ? Offset(0.0, overflowHeight) : Offset.zero;
        nextSize = Size(
          nextSize.width,
          isAbove ? nextSize.height + navButton.size.height : nextSize.height,
        );
      } else {
        navButtonParentData.offset = Offset(fitWidth, 0.0);
        nextSize = Size(nextSize.width + navButton.size.width, nextSize.height);
      }
    } else {
      navButtonParentData.shouldPaint = false;
    }

    size = nextSize;
  }

  @override
  void performLayout() {
    _lastIndexThatFits = -1;
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    _layoutChildren();
    _placeChildren();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    visitChildren((RenderObject renderObjectChild) {
      final RenderBox child = renderObjectChild as RenderBox;
      final ToolbarItemsParentData childParentData =
          child.parentData! as ToolbarItemsParentData;
      if (!childParentData.shouldPaint) {
        return;
      }

      context.paintChild(child, childParentData.offset + offset);
    });
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ToolbarItemsParentData) {
      child.parentData = ToolbarItemsParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    while (child != null) {
      // The x, y parameters have the top left of the node's box as the origin.
      final ToolbarItemsParentData childParentData =
          child.parentData! as ToolbarItemsParentData;

      // Don't hit test children aren't shown.
      if (!childParentData.shouldPaint) {
        child = childParentData.previousSibling;
        continue;
      }

      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) return true;
      child = childParentData.previousSibling;
    }
    return false;
  }

  // Visit only the children that should be painted.
  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitChildren((RenderObject renderObjectChild) {
      final RenderBox child = renderObjectChild as RenderBox;
      final ToolbarItemsParentData childParentData =
          child.parentData! as ToolbarItemsParentData;
      if (childParentData.shouldPaint) {
        visitor(renderObjectChild);
      }
    });
  }
}

// The Material-styled toolbar outline. Fill it with any widgets you want. No
// overflow ability.
class _TextSelectionToolbarContainer extends StatelessWidget {
  const _TextSelectionToolbarContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      // This value was eyeballed to match the native text selection menu on
      // a Pixel 2 running Android 10.
      borderRadius: const BorderRadius.all(Radius.circular(7.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 1.0,
      type: MaterialType.card,
      child: child,
    );
  }
}

// A button styled like a Material native Android text selection overflow menu
// forward and back controls.
class _TextSelectionToolbarOverflowButton extends StatelessWidget {
  const _TextSelectionToolbarOverflowButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  }) : super(key: key);

  final Icon icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      color: const Color(0x00000000),
      child: IconButton(
        // TODO(justinmc): This should be an AnimatedIcon, but
        // AnimatedIcons doesn't yet support arrow_back to more_vert.
        // https://github.com/flutter/flutter/issues/51209
        icon: icon,
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
    */

//class CustomToolBar extends TextSelectionToolbar {}

