import 'package:flutter/material.dart';

/// converts screen percentage to a pixel height
/// or pixel height to screen percentage
/// to be used with (draggable widgets since they take % of screen)
double relativeHeight(context, height) => height > 1.0
    ? height / MediaQuery.of(context).size.height
    : height * MediaQuery.of(context).size.height;

/// converts pixel height to figma pixel height
double figmaHeight(context, height) =>
    MediaQuery.of(context).size.height * (height / 760);
