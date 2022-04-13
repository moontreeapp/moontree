import 'package:flutter/material.dart';

class ContainerComponents {
  Widget navBar(
    BuildContext context, {
    required Widget child,
    bool tall = false,
  }) =>
      Container(
          height:
              MediaQuery.of(context).size.height * ((tall ? 118 : 72) / 760),
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0x33000000),
                  offset: Offset(0, 5),
                  blurRadius: 5),
              BoxShadow(
                  color: const Color(0x1F000000),
                  offset: Offset(0, 3),
                  blurRadius: 14),
              BoxShadow(
                  color: const Color(0x3D000000),
                  offset: Offset(0, 8),
                  blurRadius: 10)
            ],
          ),
          child: child);
}
