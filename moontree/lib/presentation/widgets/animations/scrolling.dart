library scroll_snap_list;
//scroll_snap_list-0.9.1

import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';

class PausableSnapScrollController extends ScrollController {
  bool _ignoreSnap = false;
  PausableSnapScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset = true,
    super.debugLabel,
    super.onAttach,
    super.onDetach,
  });
  void setIgnoreSnap(bool value) => _ignoreSnap = value;
  bool get ignoreSnap => _ignoreSnap;
}

class SensitiveScrollPhysics extends ScrollPhysics {
  final double sensitivityFactor;

  SensitiveScrollPhysics(
      {required this.sensitivityFactor, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  SensitiveScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SensitiveScrollPhysics(
      sensitivityFactor: sensitivityFactor,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * sensitivityFactor);
  }
}

///Anchor location for selected item in the list
enum SelectedItemAnchor { START, MIDDLE, END }

///A ListView widget that able to "snap" or focus to an item whenever user scrolls.
///
///Allows unrestricted scroll speed. Snap/focus event done on every `ScrollEndNotification`.
///
///Contains `ScrollNotification` widget, so might be incompatible with other scroll notification.
class ScrollSnapList extends StatefulWidget {
  ///List background
  final Color? background;

  ///Widget builder.
  final Widget Function(BuildContext, int) itemBuilder;

  ///Animation curve
  final Curve curve;

  ///Animation duration in milliseconds (ms)
  final Duration duration;

  ///Pixel tolerance to trigger onReachEnd.
  ///Default is itemSize/2
  final double? endOfListTolerance;

  ///Focus to an item when user tap on it. Inactive if the list-item have its own onTap detector (use state-key to help focusing instead).
  final bool focusOnItemTap;

  ///Method to manually trigger focus to an item. Call with help of `GlobalKey<ScrollSnapListState>`.
  final void Function(int)? focusToItem;

  ///Method hook
  final void Function(int)? onTapPreFocus;

  ///Method hook
  final void Function(int)? onTapPostFocus;

  ///Method hook
  final void Function(int)? onLongPressPreFocus;

  ///Method hook
  final void Function(int)? onLongPressPostFocus;

  ///Method hook
  final void Function()? onBackgroundTap;

  ///Method hook
  final void Function()? onScrollStart;

  ///Method hook
  final void Function()? onBackgroundTapDown;

  ///Method hook
  final void Function(DragEndDetails)? onBackgroundFlick;

  ///Method hook
  final void Function(int, DragEndDetails)? onFlick;

  ///Container's margin
  final EdgeInsetsGeometry? margin;

  ///Number of item in this list
  final int itemCount;

  ///Composed of the size of each item + its margin/padding.
  ///Size used is width if `scrollDirection` is `Axis.horizontal`, height if `Axis.vertical`.
  ///
  ///Example:
  ///- Horizontal list
  ///- Card with `width` 100
  ///- Margin is `EdgeInsets.symmetric(horizontal: 5)`
  ///- itemSize is `100+5+5 = 110`
  final double itemSize;

  ///Indicator overlay height
  final double indicatorHeight;

  ///Global key that's used to call `focusToItem` method to manually trigger focus event.
  final Key? key;

  ///Global key that passed to child ListView. Can be used for PageStorageKey
  final Key? listViewKey;

  ///Callback function when list snaps/focuses to an item
  final void Function(int) onItemFocus;

  ///Callback function when list snapped/focused to an item
  final void Function(int)? onItemFocused;

  ///Callback function when user reach end of list.
  ///
  ///Can be used to load more data from database.
  final Function? onReachEnd;

  ///Container's padding
  final EdgeInsetsGeometry? padding;

  ///Container's padding
  final EdgeInsetsGeometry? indicatorPadding;

  ///Reverse scrollDirection
  final bool reverse;

  ///Calls onItemFocus (if it exists) when ScrollUpdateNotification fires
  final bool? updateOnScroll;

  ///An optional initial position which will not snap until after the first drag
  final double? initialIndex;

  ///ListView's scrollDirection
  final Axis scrollDirection;

  ///Allows external controller
  final ScrollController listController;

  ///Scale item's size depending on distance to center
  final bool dynamicItemSize;

  ///Custom equation to determine dynamic item scaling calculation
  ///
  ///Input parameter is distance between item position and center of ScrollSnapList (Negative for left side, positive for right side)
  ///
  ///Output value is scale size (must be >=0, 1 is normal-size)
  ///
  ///Need to set `dynamicItemSize` to `true`
  final double Function(double distance)? dynamicSizeEquation;

  ///Custom Opacity of items off center
  final double? dynamicItemOpacity;

  ///Anchor location for selected item in the list
  final SelectedItemAnchor selectedItemAnchor;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? scrollPhysics;

  ///{@macro flutter.material.Material.clipBehavior}
  final Clip clipBehavior;

  ///{@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  ///Allow List items to be scrolled using other direction
  ///(e.g scroll items vertically if `ScrollSnapList` axis is `Axis.horizontal`)
  final bool allowAnotherDirection;

  ///If set to false(default) scroll notification bubbling will be canceled. Set to true to
  ///dispatch notifications to further ancestors.
  final bool dispatchScrollNotifications;

  final EdgeInsetsGeometry? listViewPadding;

  ///alignment of the items in the list defaults to Alignment.center
  final Alignment? alignment;

  ///alignment of the indicator overlay
  final Alignment indicatorAlignment;

  ///snap to the first element when scrolling hard
  final bool snapHome;

  /// scroll sensitivity
  final double? sensitivity;

  ScrollSnapList({
    this.background,
    required this.itemBuilder,
    ScrollController? listController,
    this.curve = Curves.ease,
    this.allowAnotherDirection = true,
    this.duration = const Duration(milliseconds: 300),
    this.endOfListTolerance,
    this.focusOnItemTap = true,
    this.focusToItem,
    this.onFlick,
    this.onBackgroundFlick,
    this.onScrollStart,
    this.onTapPreFocus,
    this.onTapPostFocus,
    this.onLongPressPreFocus,
    this.onLongPressPostFocus,
    this.onBackgroundTap,
    this.onBackgroundTapDown,
    required this.itemCount,
    required this.itemSize,
    this.key,
    this.listViewKey,
    this.margin,
    required this.onItemFocus,
    this.onItemFocused,
    this.onReachEnd,
    this.padding,
    this.indicatorPadding,
    this.indicatorAlignment = Alignment.center,
    this.reverse = false,
    this.updateOnScroll,
    this.initialIndex,
    this.scrollDirection = Axis.horizontal,
    this.dynamicItemSize = false,
    this.dynamicSizeEquation,
    this.dynamicItemOpacity,
    this.selectedItemAnchor = SelectedItemAnchor.MIDDLE,
    this.shrinkWrap = false,
    this.scrollPhysics,
    this.clipBehavior = Clip.hardEdge,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.dispatchScrollNotifications = false,
    this.listViewPadding,
    this.alignment = Alignment.center,
    this.indicatorHeight = 50.0,
    this.snapHome = true,
    this.sensitivity,
  })  : listController = listController ?? ScrollController(),
        super(key: key);

  @override
  ScrollSnapListState createState() => ScrollSnapListState();
}

class ScrollSnapListState extends State<ScrollSnapList> {
  //true if initialIndex exists and first drag hasn't occurred
  bool isInit = true;

  //to avoid multiple onItemFocus when using updateOnScroll
  int previousIndex = -1;

  //Current scroll-position in pixel
  double currentPixel = 0;

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex != null) {
        //set list's initial position
        focusToInitialPosition();
      } else {
        isInit = false;
      }
    });

    ///After initial jump, set isInit to false
    Future.delayed(Duration(milliseconds: 10), () {
      if (this.mounted) {
        setState(() {
          isInit = false;
        });
      }
    }).then((_) {
      if (widget.onItemFocused != null) {
        widget.onItemFocused!(previousIndex);
      }
    });
  }

  ///Scroll list to an offset
  void _animateScroll(double location) {
    Future.delayed(Duration.zero, () {
      if (this.mounted) {
        widget.listController
            .animateTo(
          location,
          duration: widget.duration,
          curve: widget.curve,
        )
            .then((_) {
          if (widget.onItemFocused != null) {
            widget.onItemFocused!(previousIndex);
          }
        });
      }
    });
  }

  ///Calculate scale transformation for dynamic item size
  double calculateScale(int index) {
    //scroll-pixel position for index to be at the center of ScrollSnapList
    double intendedPixel = index * widget.itemSize;
    double difference = intendedPixel - currentPixel;

    if (widget.dynamicSizeEquation != null) {
      //force to be >= 0
      double scale = widget.dynamicSizeEquation!(difference);
      return scale < 0 ? 0 : scale;
    }

    //default equation
    return 1 - min(difference.abs() / 500, 0.4);
  }

  ///Calculate opacity transformation for dynamic item opacity
  double calculateOpacity(int index) {
    //scroll-pixel position for index to be at the center of ScrollSnapList
    double intendedPixel = index * widget.itemSize;
    double difference = intendedPixel - currentPixel;

    return (difference == 0) ? 1.0 : widget.dynamicItemOpacity ?? 1.0;
  }

  Widget _buildListItem(BuildContext context, int index) {
    Widget child;
    if (widget.dynamicItemSize) {
      child = Transform.scale(
        scale: calculateScale(index),
        child: widget.itemBuilder(context, index),
        alignment: widget.alignment,
      );
    } else {
      child = widget.itemBuilder(context, index);
    }
    if (widget.dynamicItemOpacity != null) {
      child = Opacity(child: child, opacity: calculateOpacity(index));
    }
    if (widget.focusOnItemTap)
      return GestureDetector(
        onVerticalDragEnd: (details) {
          if (widget.onFlick != null) {
            widget.onFlick!(index, details);
          }
        },
        onTap: () {
          if (widget.onTapPreFocus != null) {
            widget.onTapPreFocus!(index);
          }
          focusToItem(index);
          if (widget.onTapPostFocus != null) {
            widget.onTapPostFocus!(index);
          }
        },
        onLongPress: () {
          if (widget.onLongPressPreFocus != null) {
            widget.onLongPressPreFocus!(index);
          }
          focusToItem(index);
          if (widget.onLongPressPostFocus != null) {
            widget.onLongPressPostFocus!(index);
          }
        },
        child: child,
      );

    return child;
  }

  ///Calculates card index for scroll animation
  ///
  ///Then trigger `onItemFocus`
  int _calcCardIndex({
    double? pixel,
    required double itemSize,
    int? index,
  }) {
    //current pixel: pixel
    //listPadding is not considered as moving pixel by scroll (0.0 is after padding)
    //substracted by itemSize/2 (to center the item)
    //divided by pixels taken by each item
    int cardIndex =
        index != null ? index : ((pixel! - itemSize / 2) / itemSize).ceil();
    //Avoid index getting out of bounds
    if (cardIndex < 0) {
      cardIndex = 0;
    } else if (cardIndex > widget.itemCount - 1) {
      cardIndex = widget.itemCount - 1;
    }
    return cardIndex;
  }

  ///Calculates target pixel for scroll animation
  ///
  ///Then trigger `onItemFocus`
  double _calcCardLocation({
    double? pixel,
    required double itemSize,
    int? index,
  }) {
    final int cardIndex = _calcCardIndex(
      pixel: pixel,
      itemSize: itemSize,
      index: index,
    );
    //trigger onItemFocus
    if (cardIndex != previousIndex) {
      previousIndex = cardIndex;
      widget.onItemFocus(cardIndex);
    }

    //target position
    return (cardIndex * itemSize);
  }

  /// Trigger focus to an item inside the list
  /// Will trigger scoll animation to focused item
  void focusToItem(int index) {
    double targetLoc =
        _calcCardLocation(index: index, itemSize: widget.itemSize);
    _animateScroll(targetLoc);
  }

  ///Determine location if initialIndex is set
  void focusToInitialPosition() {
    if (mounted) {
      widget.listController.jumpTo((widget.initialIndex! * widget.itemSize));
    }
  }

  ///Trigger callback on reach end-of-list
  void _onReachEnd() {
    if (widget.onReachEnd != null) widget.onReachEnd!();
  }

  @override
  void dispose() {
    if (mounted) {
      widget.listController.dispose();
    }
    super.dispose();
  }

  /// Calculate List Padding by checking SelectedItemAnchor
  /// fyi I don't think this has any effect.
  double calculateListPadding(BoxConstraints constraint) {
    switch (widget.selectedItemAnchor) {
      case SelectedItemAnchor.MIDDLE:
        return (widget.scrollDirection == Axis.horizontal
                    ? constraint.maxWidth
                    : constraint.maxHeight) /
                2 -
            widget.itemSize / 2;
      case SelectedItemAnchor.END:
        return (widget.scrollDirection == Axis.horizontal
                ? constraint.maxWidth
                : constraint.maxHeight) -
            widget.itemSize;
      case SelectedItemAnchor.START:
      default:
        return 0;
    }
  }

  double _previousOffset = 0.0;
  DateTime _previousTimestamp = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: widget.indicatorAlignment, children: [
      Container(
        padding: widget.padding,
        margin: widget.margin,
        //decoration: BoxDecoration(
        //  borderRadius: BorderRadius.circular(100),
        //  color: Colors.green,
        //),
        child: LayoutBuilder(
          builder: (BuildContext ctx, BoxConstraints constraint) {
            double _listPadding = calculateListPadding(constraint);
            return GestureDetector(
              //by catching onTapDown gesture, it's possible to keep animateTo from removing user's scroll listener
              behavior: HitTestBehavior.translucent,
              onTapDown: (_) {
                if (widget.onBackgroundTapDown != null) {
                  widget.onBackgroundTapDown!();
                }
              },
              onTap: () {
                if (widget.onBackgroundTap != null) {
                  widget.onBackgroundTap!();
                }
              },
              onVerticalDragEnd: (details) {
                if (widget.onBackgroundFlick != null) {
                  widget.onBackgroundFlick!(details);
                }
              },

              /// ignored -- must do it manually in onNotification
              //onHorizontalDragEnd: (details) {
              //  print(details.primaryVelocity);
              //  if ((details.primaryVelocity ?? 0) > 5000) {
              //    print(
              //        '------------------------detected ${details.primaryVelocity}');
              //  }
              //},
              //onHorizontalDragDown: (details) {
              //  if (widget.onScrollStart != null) {
              //    widget.onScrollStart!();
              //  }
              //},
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  // Check if the received gestures are coming directly from the
                  // ScrollSnapList. If not, skip them. Try to avoid inifinte
                  // animation loop caused by multi-level NotificationListener
                  if (scrollInfo.depth > 0) {
                    //print('scrollInfo.depth > 0');
                    return false;
                  }

                  if (!widget.allowAnotherDirection) {
                    if (scrollInfo.metrics.axisDirection ==
                            AxisDirection.right ||
                        scrollInfo.metrics.axisDirection ==
                            AxisDirection.left) {
                      if (widget.scrollDirection != Axis.horizontal) {
                        return false;
                      }
                    }

                    if (scrollInfo.metrics.axisDirection == AxisDirection.up ||
                        scrollInfo.metrics.axisDirection ==
                            AxisDirection.down) {
                      if (widget.scrollDirection != Axis.vertical) {
                        return false;
                      }
                    }
                  }
                  //if (scrollInfo is ScrollStartNotification) {
                  //  if (widget.onScrollStart != null) {
                  //    widget.onScrollStart!();
                  //  }
                  //} else
                  if (scrollInfo is ScrollEndNotification) {
                    // don't worry about snapping if ignoreSnap
                    if (mounted &&
                        widget.listController is PausableSnapScrollController &&
                        (widget.listController as PausableSnapScrollController)
                            .ignoreSnap) {
                      return true;
                    }
                    // dont snap until after first drag
                    if (isInit) {
                      return true;
                    }

                    double tolerance =
                        widget.endOfListTolerance ?? (widget.itemSize / 2);
                    if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - tolerance) {
                      _onReachEnd();
                    }

                    // snap the selection
                    double offset = _calcCardLocation(
                      pixel: scrollInfo.metrics.pixels,
                      itemSize: widget.itemSize,
                    );

                    // only animate if not yet snapped (tolerance 0.01 pixel)
                    if ((scrollInfo.metrics.pixels - offset).abs() > 0.01) {
                      _animateScroll(offset);
                    }
                  } else if (scrollInfo is ScrollUpdateNotification) {
                    if (widget.snapHome) {
                      // Calculate scroll velocity
                      final double offset = scrollInfo.metrics.pixels;
                      final DateTime now = DateTime.now();
                      final double deltaTime = now
                          .difference(_previousTimestamp)
                          .inMilliseconds
                          .toDouble();
                      if (deltaTime > 250) {
                        final double deltaY = offset - _previousOffset;
                        final double velocity = deltaY / deltaTime;
                        if (velocity < -6.25) {
                          focusToItem(0);
                        }
                        _previousOffset = offset;
                        _previousTimestamp = now;
                      }
                    }
                    //save pixel position for scale-effect
                    if (widget.dynamicItemSize ||
                        widget.dynamicItemOpacity != null) {
                      setState(() {
                        currentPixel = scrollInfo.metrics.pixels;
                      });
                    }

                    if (widget.updateOnScroll == true) {
                      // dont snap until after first drag
                      if (isInit) {
                        return true;
                      }

                      if (isInit == false) {
                        _calcCardLocation(
                          pixel: scrollInfo.metrics.pixels,
                          itemSize: widget.itemSize,
                        );
                      }
                    }
                  }
                  return !widget.dispatchScrollNotifications;
                },
                child: ListView.builder(
                  physics: widget.scrollPhysics ??
                      (widget.sensitivity != null
                          ? SensitiveScrollPhysics(
                              sensitivityFactor: widget.sensitivity!)
                          : null),
                  key: widget.listViewKey,
                  controller: widget.listController,
                  clipBehavior: widget.clipBehavior,
                  keyboardDismissBehavior: widget.keyboardDismissBehavior,
                  padding: widget.listViewPadding ??
                      (widget.scrollDirection == Axis.horizontal
                          ? EdgeInsets.symmetric(
                              horizontal: max(
                              0,
                              _listPadding,
                            ))
                          : EdgeInsets.symmetric(
                              vertical: max(
                                0,
                                _listPadding,
                              ),
                            )),
                  reverse: widget.reverse,
                  scrollDirection: widget.scrollDirection,
                  itemBuilder: _buildListItem,
                  itemCount: widget.itemCount,
                  shrinkWrap: widget.shrinkWrap,
                ),
              ),
            );
          },
        ),
      ),
      // not sure if htis is needed at all since we're moving the indicator away
      //final StreamController<bool> _showIndicator = StreamController<bool>();
      /*Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          StreamBuilder<bool>(
            stream: _showIndicator.stream,
            initialData: true,
            builder: (context, snapshot) {
              if (widget.indicatorHeight == 0 || snapshot.data == false) {
                return const SizedBox.shrink(); //FadeOut(child: CenterIcon());
              } else {
                //return Container(
                //    decoration: BoxDecoration(
                //        borderRadius: BorderRadius.circular(100),
                //        boxShadow: [
                //          BoxShadow(
                //            color: Colors.black,
                //            blurRadius: 3.0,
                //            offset: Offset(1.0, 2.0),
                //          ),
                //        ]),
                return FadeIn(
                    child: Padding(
                        padding: widget.indicatorPadding ?? EdgeInsets.zero,
                        child: CenterIcon(size: widget.indicatorHeight)));
              }
            },
          ),
        ],
      )*/
    ]);
  }
}
