import 'package:flutter/material.dart';
import 'package:raven_front/utils/size.dart';

extension RelativeHeightDoble on double {
  double figma(BuildContext context) => figmaHeight(context, this);
  double ofMediaHeight(BuildContext context) => relativeHeight(context, this);
  double ofMediaHeightMinusNavbar(BuildContext context, {bool tall = true}) =>
      relativeHeight(context, this, heightMinus(context, tall ? 118 : 72));
}

extension RelativeHeightInt on int {
  double figma(BuildContext context) => figmaHeight(context, this);
  double ofMediaHeight(BuildContext context) => relativeHeight(context, this);
  double ofMediaHeightMinusNavbar(BuildContext context, {bool tall = true}) =>
      relativeHeight(context, this, heightMinus(context, tall ? 118 : 72));
}
