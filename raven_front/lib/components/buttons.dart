import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class ButtonComponents {
  IconButton back(BuildContext context) => IconButton(
      icon: components.icons.back, onPressed: () => Navigator.pop(context));

  Widget actionButton(
    BuildContext context, {
    required String label,
    required Widget icon,
    Widget? disabledIcon,
    String? link,
    VoidCallback? onPressed,
    bool enabled = true,
  }) =>
      Expanded(
          child: Container(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: enabled
                    ? (link != null
                        ? () => Navigator.of(components.navigator.routeContext!)
                            .pushNamed(link)
                        : onPressed ?? () {})
                    : () {},
                icon: enabled ? icon : (disabledIcon ?? icon),
                label: Text(label.toUpperCase(),
                    style: enabled
                        ? /*Theme.of(context).enabledButton*/ null
                        : Theme.of(context).disabledButton),
                style: components.styles.buttons
                    .bottom(context, disabled: !enabled),
              )));
}
