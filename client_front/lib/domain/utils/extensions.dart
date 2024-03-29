import 'dart:ui' as ui;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:client_front/domain/utils/size.dart' as size;
import 'package:client_front/presentation/components/components.dart'
    as components;
/*
.figma(context)      // for use in builders
.figmaH             // entire screen (sizing)
.figmaW            // entire screen
.figmaSafeHeight  // entire screen minus system toolbar
.figmaAppHeight  // entire scren minus system toolbar and fixed appbar (spacing)
.ofMediaHeight(context)  // for use in builders
.ofMediaWidth(context)  // for use in builders
.ofScreenHeight        // entire screen  
.ofScreenWidth        // entire screen
.ofSafeHeight        // entire screen minus system toolbar
.ofAppHeight        // entire screen minus system toolbar and fixed app bar
*/

extension RelativeHeightDoble on num {
  double figma(BuildContext context) =>
      size.relativeHeight(context, (this / 760));

  double get figmaH =>
      size.relativeHeight(components.routes.routeContext!, (this / 760));

  double get figmaW =>
      size.relativeWidth(components.routes.routeContext!, this / 360);

  double get figmaSafeHeight => size.relativeHeight(
        components.routes.routeContext!,
        (this / 680),
        minus: systemBarHeight,
      );

  double get figmaAppHeight => size.relativeHeight(
        components.routes.routeContext!,
        (this / 680),
        minus: (systemBarHeight + appBarHeight),
      );

  double ofMediaHeight(BuildContext context) =>
      size.relativeHeight(context, this);

  double ofMediaHeightMinusNavbar(BuildContext context, {bool tall = true}) =>
      size.relativeHeight(context, this, minus: tall ? 118 : 72);

  double get ofScreenHeight => size.relativeHeight(
        components.routes.routeContext!,
        this,
      );

  double get ofSafeHeight => size.relativeHeight(
        components.routes.routeContext!,
        this,
        minus: systemBarHeight,
      );

  double get ofAppHeight => size.relativeHeight(
        components.routes.routeContext!,
        this,
        minus: (systemBarHeight + appBarHeight + optionalAndroidNav),
      );

  double ofMediaWidth(BuildContext context) =>
      size.relativeWidth(context, this);

  double get ofScreenWidth =>
      size.relativeWidth(components.routes.routeContext!, this);

  static double get appBarHeight => 56.0;

  double get systemBarHeight =>
      // deprecated
      //MediaQueryData.fromView(ui.window).viewPadding.top;
      MediaQueryData.fromView(ui.PlatformDispatcher.instance.views.first)
          .viewPadding
          .top;

  double get optionalAndroidNav => Platform.isAndroid ? 48.0 : 0.0;
}
