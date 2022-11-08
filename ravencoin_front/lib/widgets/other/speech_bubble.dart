import 'dart:math';

import 'package:flutter/material.dart';

enum NipLocation {
  top,
  right,
  bottom,
  left,
  bottomRight,
  bottomLeft,
  topRight,
  topLeft
}

class SpeechBubble extends StatelessWidget {
  /// Creates a widget that emulates a speech bubble.
  /// Could be used for a tooltip, or as a pop-up notification, etc.
  SpeechBubble({
    Key? key,
    required this.child,
    this.nipLocation = NipLocation.top,
    this.color = Colors.white,
    this.borderRadius = 200.0,
    this.height,
    this.width,
    this.padding =
        const EdgeInsets.only(top: 2.0, left: 12.0, right: 12.0, bottom: 2.0),
    this.nipHeight = 6.0,
    this.nipOffCenter = 0.0,
    this.nipBorderRadius = 0,
    this.offset = Offset.zero,
  }) : super(key: key);

  /// The [child] contained by the [SpeechBubble]
  final Widget child;

  /// The location of the nip of the speech bubble.
  ///
  /// Use [NipLocation] enum, either [TOP], [RIGHT], [BOTTOM], or [LEFT].
  /// The nip will automatically center to the side that it is assigned.
  final NipLocation nipLocation;

  /// The color of the body of the [SpeechBubble] and nip.
  /// Defaultly red.
  final Color color;

  /// The [borderRadius] of the [SpeechBubble].
  /// The [SpeechBubble] is built with a
  /// circular border radius on all 4 corners.
  final double borderRadius;

  /// The explicitly defined height of the [SpeechBubble].
  /// The [SpeechBubble] will defaultly enclose its [child].
  final double? height;

  /// The explicitly defined width of the [SpeechBubble].
  /// The [SpeechBubble] will defaultly enclose its [child].
  final double? width;

  /// The padding between the child and the edges of the [SpeechBubble].
  final EdgeInsetsGeometry? padding;

  /// The nip height
  final double nipHeight;

  /// The nip off center
  final double nipOffCenter;

  /// The nip off center
  final double nipBorderRadius;

  final Offset offset;

  Widget build(BuildContext context) {
    Offset? nipOffset;
    AlignmentGeometry? alignment;
    var rotatedNipHalfHeight = getNipHeight(nipHeight) / 2;
    var offset = (nipHeight / 2 + rotatedNipHalfHeight) - (nipBorderRadius / 2);
    switch (nipLocation) {
      case NipLocation.top:
        nipOffset = Offset(nipOffCenter, -offset + rotatedNipHalfHeight);
        alignment = Alignment.topCenter;
        break;
      case NipLocation.right:
        nipOffset = Offset(offset - rotatedNipHalfHeight, nipOffCenter);
        alignment = Alignment.centerRight;
        break;
      case NipLocation.bottom:
        nipOffset = Offset(nipOffCenter, offset - rotatedNipHalfHeight);
        alignment = Alignment.bottomCenter;
        break;
      case NipLocation.left:
        nipOffset = Offset(-offset + rotatedNipHalfHeight, nipOffCenter);
        alignment = Alignment.centerLeft;
        break;
      case NipLocation.bottomLeft:
        nipOffset = this.offset +
            Offset(
                offset - rotatedNipHalfHeight, offset - rotatedNipHalfHeight);
        alignment = Alignment.bottomLeft;
        break;
      case NipLocation.bottomRight:
        nipOffset = this.offset +
            Offset(
                -offset + rotatedNipHalfHeight, offset - rotatedNipHalfHeight);
        alignment = Alignment.bottomRight;
        break;
      case NipLocation.topLeft:
        nipOffset = this.offset +
            Offset(
                offset - rotatedNipHalfHeight, -offset + rotatedNipHalfHeight);
        alignment = Alignment.topLeft;
        break;
      case NipLocation.topRight:
        nipOffset = this.offset +
            Offset(
                -offset + rotatedNipHalfHeight, -offset + rotatedNipHalfHeight);
        alignment = Alignment.topRight;
        break;
      default:
    }

    return Stack(
      alignment: alignment!,
      children: <Widget>[
        speechBubble(),
        nip(nipOffset!),
      ],
    );
  }

  Widget speechBubble() {
    return Material(
      borderRadius: BorderRadius.all(
        Radius.circular(borderRadius),
      ),
      color: color,
      elevation: 1.0,
      child: Container(
        height: height,
        width: width,
        padding: padding,
        child: child,
      ),
    );
  }

  Widget nip(Offset nipOffset) {
    return Transform.translate(
      offset: nipOffset,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(45 / 360),
        child: Material(
          borderRadius: BorderRadius.all(
            Radius.circular(nipBorderRadius),
          ),
          color: color,
          child: Container(
            height: nipHeight,
            width: nipHeight,
          ),
        ),
      ),
    );
  }

  double getNipHeight(double nipHeight) => sqrt(2 * pow(nipHeight, 2));
}
