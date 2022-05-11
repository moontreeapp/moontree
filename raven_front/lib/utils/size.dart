import 'package:flutter/material.dart';

/// converts screen percentage to a pixel height
/// or pixel height to screen percentage
/// to be used with (draggable widgets since they take % of screen)
double relativeHeight(context, num height, {num minus = 0}) => height > 1.0
    ? height / (MediaQuery.of(context).size.height - minus)
    : height * (MediaQuery.of(context).size.height - minus);

/// converts screen percentage to a pixel height
/// or pixel height to screen percentage
/// to be used with (draggable widgets since they take % of screen)
double relativeWidth(context, num width, [double? givenWidth]) => width > 1.0
    ? width / (givenWidth ?? MediaQuery.of(context).size.width)
    : width * (givenWidth ?? MediaQuery.of(context).size.width);
