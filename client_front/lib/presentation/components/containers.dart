import 'package:flutter/material.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/other/keyboard_delayed.dart';
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;

class ContainerComponents {
  const ContainerComponents();
  Widget navBar(
    BuildContext context, {
    required Widget child,
    bool tall = false,
  }) =>
      KeyboardHidesWidgetWithDelay(
          child: Container(
              height: (tall ? 118 : 72).figma(context),
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 0),
              //width: MediaQuery.of(context).size.width,
              alignment: Alignment.topCenter,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: shapes.topRoundedBorder16,
                boxShadow: shadows.navBar,
              ),
              child: child));
}
