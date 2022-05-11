import 'package:flutter/material.dart';

/// converts pixel height to figma pixel height
double figmaHeight(context, height) =>
    MediaQuery.of(context).size.height * (height / 760);

/// converts screen percentage to a pixel height
/// or pixel height to screen percentage
/// to be used with (draggable widgets since they take % of screen)
double relativeHeight(context, num height, [double? givenHeight]) =>
    height > 1.0
        ? height / (givenHeight ?? MediaQuery.of(context).size.height)
        : height * (givenHeight ?? MediaQuery.of(context).size.height);

/// converts screen percentage to a pixel height
/// or pixel height to screen percentage
/// to be used with (draggable widgets since they take % of screen)
double relativeWidth(context, num width, [double? givenWidth]) => width > 1.0
    ? width / (givenWidth ?? MediaQuery.of(context).size.width)
    : width * (givenWidth ?? MediaQuery.of(context).size.width);

double heightMinus(context, double height) =>
    MediaQuery.of(context).size.height - relativeHeight(context, height);
