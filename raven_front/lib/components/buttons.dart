import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class ButtonComponents {
  IconButton back(BuildContext context) => IconButton(
      icon: components.icons.back, onPressed: () => Navigator.pop(context));

  Widget actionButton(
    BuildContext context, {
    String? label,
    Widget? icon,
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
                icon: enabled
                    ? _iconDefault(icon)
                    : _iconDefaultDisabled(disabledIcon),
                label: Text(_labelDefault(label),
                    style: enabled
                        ? /*Theme.of(context).enabledButton*/ null
                        : Theme.of(context).disabledButton),
                style: components.styles.buttons
                    .bottom(context, disabled: !enabled),
              )));

  Widget _iconDefault(Widget? icon) => icon ?? components.icons.preview;
  Widget _iconDefaultDisabled(Widget? icon) =>
      icon ?? components.icons.disabledPreview;
  String _labelDefault(String? label) => (label ?? 'Preview').toUpperCase();
}
