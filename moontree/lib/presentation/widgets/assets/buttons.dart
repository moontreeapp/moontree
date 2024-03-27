import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/services/services.dart' as uiservices;

final _borderMaterialShape =
    MaterialStateProperty.all(BorderSide(color: AppColors.primary, width: 2.0));
final _disabledBorderMaterialShape = MaterialStateProperty.all(
    BorderSide(color: AppColors.disabled, width: 2.0));
final _buttonMaterialShape = MaterialStateProperty.all(RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(uiservices.screen.buttonBorderRadius)));
final _disabledMaterial = MaterialStateProperty.all(AppColors.primary38);
final _enabledMaterial = MaterialStateProperty.all(AppColors.primary);
final _unfilledMaterial = MaterialStateProperty.all(AppColors.background);

final _enabledFilledButtonStyle = ButtonStyle(
  backgroundColor: _enabledMaterial,
  foregroundColor: _enabledMaterial,
  shape: _buttonMaterialShape,
);
final _disabledFilledButtonStyle = ButtonStyle(
  backgroundColor: _disabledMaterial,
  foregroundColor: _disabledMaterial,
  shape: _buttonMaterialShape,
);

final _enabledButtonStyle = ButtonStyle(
  backgroundColor: _unfilledMaterial,
  foregroundColor: _enabledMaterial,
  shape: _buttonMaterialShape,
  side: _borderMaterialShape,
);
final _disabledButtonStyle = ButtonStyle(
  backgroundColor: _unfilledMaterial,
  foregroundColor: _disabledMaterial,
  shape: _buttonMaterialShape,
  side: _disabledBorderMaterialShape,
);

class ButtonFormatted extends StatelessWidget {
  final double? height;
  final Color? enabledColor;
  final Color? disabledColor;
  final Widget? icon;
  final String? label;
  final Widget? disabledIcon;
  final String? link;
  final Map<String, dynamic>? arguments;
  final VoidCallback? onPressed;
  final VoidCallback? disabledOnPressed;
  final FocusNode? focusNode;
  final bool bold;
  final bool enabled;
  final bool filled;
  const ButtonFormatted({
    super.key,
    this.height,
    this.enabledColor,
    this.disabledColor,
    this.icon,
    this.label,
    this.disabledIcon,
    this.link,
    this.arguments,
    this.onPressed,
    this.disabledOnPressed,
    this.focusNode,
    this.bold = false,
    this.enabled = true,
    this.filled = true,
  });

  ButtonStyle buttonStyle(bool enabled, bool filled) => enabled
      ? (filled ? _enabledFilledButtonStyle : _enabledButtonStyle)
      : (filled ? _disabledFilledButtonStyle : _disabledButtonStyle);

  TextStyle? buttonTextStyle(
          BuildContext context, bool enabled, bool filled, bool bold) =>
      enabled
          ? (filled
              ? Theme.of(context).textTheme.enabledButton.copyWith(
                  fontWeight: bold ? FontWeights.bold : FontWeights.semiBold)
              : Theme.of(context).textTheme.enabledButton.copyWith(
                  color: AppColors.primary,
                  fontWeight: bold ? FontWeights.bold : FontWeights.semiBold))
          : (filled
              ? Theme.of(context).textTheme.disabledButton.copyWith(
                  fontWeight: bold ? FontWeights.bold : FontWeights.semiBold)
              : Theme.of(context).textTheme.disabledButton.copyWith(
                  color: AppColors.primary38,
                  fontWeight: bold ? FontWeights.bold : FontWeights.semiBold));

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height ?? uiservices.screen.buttonHeight,
        child: OutlinedButton(
          focusNode: focusNode,
          onPressed: enabled
              ? (link != null
                  ? () {
                      if (onPressed != null) {
                        onPressed!();
                      }
                      //uiservices.sail.to(link, arguments: arguments);
                    }
                  : onPressed ?? () {})
              : disabledOnPressed ?? () {},
          style: buttonStyle(enabled, filled),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: icon!,
                ),
              Text(
                _labelDefault(label),
                style: buttonTextStyle(context, enabled, filled, bold),
              ),
            ],
          ),
        ),
      );
}

class BigButton extends StatelessWidget {
  final double? height;
  final String? label;
  final Widget? disabledIcon;
  final String? link;
  final Map<String, dynamic>? arguments;
  final VoidCallback? onPressed;
  final VoidCallback? disabledOnPressed;
  final FocusNode? focusNode;
  final bool bold;
  final bool enabled;
  final bool filled;
  const BigButton({
    super.key,
    this.height = 56,
    this.label,
    this.disabledIcon,
    this.link,
    this.arguments,
    this.onPressed,
    this.disabledOnPressed,
    this.focusNode,
    this.bold = false,
    this.enabled = true,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height ?? uiservices.screen.buttonHeight,
        child: Theme(
          data: Theme.of(context).copyWith(
            buttonTheme: ButtonThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(250)),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                overlayColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.transparent),
                elevation: MaterialStateProperty.all(0),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(250))),
              ),
            ),
          ),
          child: OutlinedButton(
            focusNode: focusNode,
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                overlayColor: MaterialStateProperty.all(
                    Colors.transparent), // Prevent overlay color
                elevation:
                    MaterialStateProperty.all(0), // Remove elevation shadow
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(250)))),
            onPressed: enabled
                ? (link != null
                    ? () {
                        if (onPressed != null) {
                          onPressed!();
                        }
                        //uiservices.sail.to(link, arguments: arguments);
                      }
                    : onPressed ?? () {})
                : disabledOnPressed ?? () {},
            child: Text(
              _labelDefault(label),
              style: Theme.of(context).textTheme.enabledButton.copyWith(
                  fontWeight: bold ? FontWeights.bold : FontWeights.semiBold,
                  color: Colors.black87),
            ),
          ),
        ),
      );
}

AlignmentGeometry alignmentFromAngle(double angle) {
  // Convert angle to radians
  double angleInRadians = (angle - 90) * (pi / 180.0);
  // Calculate x and y based on the angle
  double x = cos(angleInRadians);
  double y = sin(angleInRadians);
  return Alignment(x, y);
}

class GradientButtonFormatted extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  const GradientButtonFormatted({super.key, this.onPressed, this.child});

  @override
  Widget build(BuildContext context) => SizedBox(
      height: uiservices.screen.buttonHeight,
      child: GestureDetector(
        onTap: onPressed,
        child: Opacity(
          opacity: .87,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                gradient: LinearGradient(
                  colors: const [AppColors.primary500, AppColors.primary300],
                  begin: alignmentFromAngle(2 + 180),
                  end: alignmentFromAngle(2),
                  //begin: Alignment.bottomLeft,
                  //end: Alignment.topRight,
                ),
              ),
              child: child),
        ),
      ));
}

String _labelDefault(String? label) => (label ?? 'Continue').toUpperCase();
