import 'package:flutter/material.dart';
import 'package:raven_front/utils/size.dart';

extension RelativeHeightDoble on double {
  double ofMediaHeight(BuildContext context) => relativeHeight(context, this);
  double figma(BuildContext context) => figmaHeight(context, this);
}

extension RelativeHeightInt on int {
  double ofMediaHeight(BuildContext context) => relativeHeight(context, this);
  double figma(BuildContext context) => figmaHeight(context, this);
}
