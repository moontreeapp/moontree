import 'package:flutter/material.dart';
import 'package:moontree/services/services.dart';

class SideShadowWrapper extends StatelessWidget {
  final bool active;
  final Widget child;
  const SideShadowWrapper({
    super.key,
    required this.active,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
      height: screen.app.height,
      width: screen.width,
      decoration: BoxDecoration(
          //color: Colors.white,
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 100,
                      offset: Offset(-1, 0)),
                ]
              : null,
          border: active
              ? null
              : Border(left: BorderSide(color: Colors.black, width: .25))),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: screen.width),
              child: child)));
}
