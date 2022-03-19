import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';

class ButtonComponents {
  IconButton back(BuildContext context) => IconButton(
      icon: components.icons.back, onPressed: () => Navigator.pop(context));

  Widget actionButton(
    BuildContext context, {
    String? label,
    Widget? disabledIcon,
    String? link,
    VoidCallback? onPressed,
    VoidCallback? disabledOnPressed,
    FocusNode? focusNode,
    bool enabled = true,
    bool invert = false,
  }) =>
      Expanded(
          child: Container(
        height: 40,
        child: OutlinedButton(
          focusNode: focusNode,
          onPressed: enabled
              ? (link != null
                  ? () => Navigator.of(components.navigator.routeContext!)
                      .pushNamed(link)
                  : onPressed ?? () {})
              : disabledOnPressed ?? () {},
          style: invert
              ? components.styles.buttons.bottom(context, invert: true)
              : components.styles.buttons.bottom(context, disabled: !enabled),
          child: Text(_labelDefault(label),
              style: enabled
                  ? invert
                      ? Theme.of(context).invertButton
                      : null
                  : Theme.of(context).disabledButton),
        ),
      ));

  String _labelDefault(String? label) => (label ?? 'Preview').toUpperCase();

  Widget wordButton(
    BuildContext context, {
    required String label,
    VoidCallback? onPressed,
    bool enabled = true,
    bool chosen = false,
    double width = 98,
    int? number,
  }) =>
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            height: 24,
            child: Text(
              number?.toString() ?? '',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: AppColors.black60),
            )),
        Container(
          height: 24,
          width: width,
          child: OutlinedButton(
            onPressed: enabled ? onPressed ?? () {} : () {},
            style: chosen
                ? components.styles.buttons.word(context, chosen: true)
                : components.styles.buttons.word(context, chosen: false),
            child: Text(
              label.toLowerCase(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        )
      ]);
}
