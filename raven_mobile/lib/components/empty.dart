import 'package:flutter/material.dart';

class EmptyComponents {
  EmptyComponents();

  Container transactions(
    BuildContext context, {
    String? msg,
  }) =>
      _emptyMessage(
        context,
        icon: Icons.public,
        msg: msg ?? '\nYour transactions will appear here.\n',
      );

  Container holdings(
    BuildContext context, {
    String? msg,
  }) =>
      _emptyMessage(
        context,
        icon: Icons.savings,
        msg: msg ?? '\nYour holdings will appear here.\n',
      );

  Container message(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) =>
      _emptyMessage(
        context,
        icon: icon ?? Icons.savings,
        msg: msg,
      );

  static Container _emptyMessage(
    BuildContext context, {
    required String msg,
    IconData? icon,
  }) =>
      Container(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon ?? Icons.savings,
                size: 50.0, color: Theme.of(context).secondaryHeaderColor),
            Text(msg),
            //RavenButton.getRVN(context), // hidden for alpha
          ]));
}
