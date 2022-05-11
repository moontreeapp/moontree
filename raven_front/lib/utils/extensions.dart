import 'package:flutter/material.dart';
import 'package:raven_front/utils/size.dart';
import 'package:raven_front/components/components.dart';

/*
.ofMediaHeight(context)  // for use in builders
.ofMediaWidth(context)  // for use in builders
.ofScreenHeight        // entire screen  
.ofScreenWidth        // entire screen
.ofSafeHeight        // entire screen minus system toolbar
.ofAppHeight        // entire screen minus system toolbar and fixed app bar
*/

extension RelativeHeightDoble on double {
  double figma(BuildContext context) => figmaHeight(context, this);
  double ofMediaHeight(BuildContext context) => relativeHeight(context, this);
  double ofMediaHeightMinusNavbar(BuildContext context, {bool tall = true}) =>
      relativeHeight(context, this, heightMinus(context, tall ? 118 : 72));
  double get ofScreenHeight => relativeHeight(
        components.navigator.routeContext!,
        this,
      );
  double get ofSafeHeight =>
      relativeHeight(
        components.navigator.routeContext!,
        this,
      ) -
      24;
  double get ofAppHeight =>
      relativeHeight(
        components.navigator.routeContext!,
        this,
      ) -
      (24 + 56);
  double ofMediaWidth(BuildContext context) => relativeWidth(context, this);
  double get ofScreenWidth => relativeWidth(
        components.navigator.routeContext!,
        this,
      );
}

extension RelativeHeightInt on int {
  double figma(BuildContext context) => figmaHeight(context, this);
  double ofMediaHeight(BuildContext context) => relativeHeight(context, this);
  double ofMediaHeightMinusNavbar(BuildContext context, {bool tall = true}) =>
      relativeHeight(context, this, heightMinus(context, tall ? 118 : 72));
  double get ofScreenHeight => relativeHeight(
        components.navigator.routeContext!,
        this,
      );
  double get ofSafeHeight =>
      relativeHeight(
        components.navigator.routeContext!,
        this,
      ) -
      24;
  double get ofAppHeight =>
      relativeHeight(
        components.navigator.routeContext!,
        this,
      ) -
      (24 + 56);
  double ofMediaWidth(BuildContext context) => relativeWidth(context, this);
  double get ofScreenWidth => relativeWidth(
        components.navigator.routeContext!,
        this,
      );
}
