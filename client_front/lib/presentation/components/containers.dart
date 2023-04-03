import 'package:flutter/material.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/other/keyboard_delayed.dart';
import 'package:client_front/presentation/components/components.dart';

class ContainerComponents {
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
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: components.shape.topRoundedBorder16,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 5),
                      blurRadius: 5),
                  BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, 3),
                      blurRadius: 14),
                  BoxShadow(
                      color: Color(0x3D000000),
                      offset: Offset(0, 8),
                      blurRadius: 10)
                ],
              ),
              child: child));
}
