import 'package:flutter/material.dart';
import 'package:intersperse/src/intersperse_extensions.dart';
import 'package:raven_front/components/components.dart';
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
                      ? Theme.of(context).textTheme.invertButton
                      : null
                  : Theme.of(context).textTheme.disabledButton),
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
          height: 32,
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

  Widget floatingButtons(
    BuildContext context, {
    required List<Widget> buttons,
    List<Widget>? boxedWidgets,
    List<Widget>? columnWidgets,
    Widget? heightSpacer,
    Widget? widthSpacer,
  }) =>
      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(),
        Container(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white,
                    ],
                  ),
                ),
              ),
              Container(
                height: 80,
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 16),
                    ...<Widget>[
                      for (var button in buttons) button,
                    ].intersperse(widthSpacer ?? SizedBox(width: 16)),
                    SizedBox(width: 16),
                  ],
                ),
                decoration: BoxDecoration(color: Colors.white),
              ),
            ],
          ),
        ),
      ]);
}
