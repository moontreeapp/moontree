import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;

class BottomButton extends StatelessWidget {
  final String? label;
  final Widget? disabledIcon;
  final String? link;
  final Map<String, dynamic>? arguments;
  final VoidCallback? onPressed;
  final VoidCallback? disabledOnPressed;
  final FocusNode? focusNode;
  final bool enabled;
  final bool invert;
  final bool soft;
  const BottomButton({
    super.key,
    this.label,
    this.disabledIcon,
    this.link,
    this.arguments,
    this.onPressed,
    this.disabledOnPressed,
    this.focusNode,
    this.enabled = true,
    this.invert = false,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: uiservices.screen.buttonHeight,
        child: OutlinedButton(
          focusNode: focusNode,
          onPressed: enabled
              ? (link != null
                  ? () {
                      if (onPressed != null) {
                        onPressed!();
                      }
                      uiservices.sail.to(link, arguments: arguments);
                    }
                  : onPressed ?? () {})
              : disabledOnPressed ?? () {},
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(
                Theme.of(context).textTheme.enabledButton),
            foregroundColor: MaterialStateProperty.all(
                soft ? AppColors.black60 : AppColors.offBlack),
            side: MaterialStateProperty.all(BorderSide(
                color: !enabled
                    ? AppColors.primaryDisabled
                    : invert
                        ? AppColors.white
                        : soft
                            ? AppColors.primaries[3]
                            : Theme.of(context).backgroundColor,
                width: 2, //soft ? 1 : 2,
                style: BorderStyle.solid)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    (MediaQuery.of(context).size.height * 0.05263157895) *
                        .5))),
          ),
          child: Text(_labelDefault(label),
              style: enabled
                  ? invert
                      ? Theme.of(context).textTheme.invertButton
                      : null
                  : Theme.of(context).textTheme.disabledButton),
        ),
      );
}

String _labelDefault(String? label) => (label ?? 'Preview').toUpperCase();
