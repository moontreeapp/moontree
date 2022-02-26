import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/extensions.dart';

extension ValueColorExtension on ThemeData {
  Color? get good => this.brightness == Brightness.light
      ? Colors.green.shade800 // Color(0xFF008a0b) based off orange
      : Colors.green.shade400; // Color(0xFFb6f122); based off orange
  Color? get bad => this.brightness == Brightness.light
      ? Colors.red.shade900 // Color(0xFFb80a48) based off orange
      : Colors.red.shade500; // Color(0xFFf1224f) based off orange
  Color? get fine => this.brightness == Brightness.light
      ? Colors.grey.shade900
      : Colors.grey.shade400;
  Color? get ravenOrange => Palette.ravenOrange;
  Color? get ravenBlue => Palette.ravenBlue;
}

extension TextStyleExtension on ThemeData {
  TextStyle? get mono => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Courier',
          fontWeight: FontWeights.bold,
          color: Colors.black)
      : TextStyle(
          fontSize: 16.0, fontFamily: 'Courier', color: Colors.grey.shade200);
  TextStyle? get monoLink => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0, fontFamily: 'Courier', color: Palette.ravenBlue)
      : TextStyle(
          fontSize: 16.0, fontFamily: 'Courier', color: Palette.ravenOrange);
  TextStyle? get annotate => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade700)
      : TextStyle(
          fontSize: 14.0,
          fontStyle: FontStyle.italic,
          color: Colors.grey.shade200);

  /// from new specs
  //icon for holding size: 40x40
  //arrow for holding size: 24x24 (7.4w 12h) #000000
  //text for holding names (subtitle1):
  TextStyle? get holdingName => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Colors.black.withOpacity(0.87));
  //text for holding values (secondarytext):
  TextStyle? get holdingValue => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.25,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.25,
          color: Colors.black.withOpacity(0.6));
  TextStyle? get pageTitle => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 20.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.15,
          color: Colors.white)
      : TextStyle(
          fontSize: 20.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.15,
          color: Colors.white);
  TextStyle? get pageValue => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.18,
          color: Colors.black.withOpacity(0.87))
      : TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.18,
          color: Colors.black.withOpacity(0.87));
  TextStyle? get drawerTitle => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.18,
          color: Colors.black.withOpacity(0.87))
      : TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.18,
          color: Colors.black.withOpacity(0.87));
  TextStyle? get drawerTitleSmall => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 18.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.15,
          color: Colors.black.withOpacity(0.87))
      : TextStyle(
          fontSize: 18.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.15,
          color: Colors.black.withOpacity(0.87));
  TextStyle? get drawerDestination => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Colors.white)
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Colors.white);
  TextStyle? get copyright => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 12.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.4,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 12.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.normal,
          letterSpacing: 0.4,
          color: Color(0xDE000000));
  TextStyle? get supportHeading => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 10.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.medium,
          letterSpacing: 1.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 10.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.medium,
          letterSpacing: 1.5,
          color: Color(0xDE000000));
  TextStyle? get supportText => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xFF000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xFF000000));
  TextStyle? get sendFeildText => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.15,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.15,
          color: Color(0x99000000));
  TextStyle? get textFieldError => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 12.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.4,
          color: Color(0xFFAA2E25))
      : TextStyle(
          fontSize: 12.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.4,
          color: Color(0xFFAA2E25));
  TextStyle? get balanceBackText => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDEFFFFFF))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDEFFFFFF));
  TextStyle? get balanceAmount => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.18,
          color: Color(0xDEFFFFFF))
      : TextStyle(
          fontSize: 24.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.18,
          color: Color(0xDEFFFFFF));
  TextStyle? get balanceDollar => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDEFFFFFF))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDEFFFFFF));
  TextStyle? get remaining => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0xDEFFFFFF))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0xDEFFFFFF));
  TextStyle? get remainingRed => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0xFFFF1900))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0xFFFF1900));
  TextStyle? get choicesHoldings => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000));
  TextStyle? get choices => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.1,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.1,
          color: Color(0x99000000));
  TextStyle? get choicesBlue => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.1,
          color: Color(0xFF5C6BC0))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.1,
          color: Color(0xFF5C6BC0));
  TextStyle? get settingDestination => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0x99000000));
  TextStyle? get securityDestination => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000));
  TextStyle? get securityDisabled => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0x61000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0x61000000));
  TextStyle? get sendConfirm => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0x99000000));
  TextStyle? get sendConfirmButton => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 1.25,
          color: Color(0xFF5C6BC0))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 1.25,
          color: Color(0xFF5C6BC0));
  TextStyle? get loaderText => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 20.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.15,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 20.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.15,
          color: Color(0xDE000000));
  TextStyle? get textButton => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 1.25,
          color: Color(0xDE5C6BC0))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 1.25,
          color: Color(0xDE5C6BC0));
  TextStyle? get disabledButton => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 1.25,
          color: Color(0x61000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 1.25,
          color: Color(0x61000000));
  TextStyle? get enabledButton => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 1.25,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 1.25,
          color: Color(0xDE000000));
  TextStyle? get importedFile => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.5,
          color: Color(0xDE000000));
  TextStyle? get importedSize => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0x61000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0x61000000));
  TextStyle? get snackMessage => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0xDEFFFFFF))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0xDEFFFFFF));
  TextStyle? get snackMessageBad => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0xFFF44336))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0xFFF44336));
  TextStyle? get txAmount => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.5,
          color: Color(0xFF000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.5,
          color: Color(0xFF000000));
  TextStyle? get txDate => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.25,
          color: Color(0x99000000));
  TextStyle? get tabName => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.medium,
          letterSpacing: 1.25,
          color: Color(0xFFFFFFFF))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.medium,
          letterSpacing: 1.25,
          color: Color(0xFFFFFFFF));
  TextStyle? get tabNameInactive => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.medium,
          letterSpacing: 1.25,
          color: Color(0x99FFFFFF))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.medium,
          letterSpacing: 1.25,
          color: Color(0x99FFFFFF));
  TextStyle? get viewData => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 1.25,
          color: Color(0xFF5C6BC0))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 1.25,
          color: Color(0xFF5C6BC0));
  TextStyle? get qrMessage => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.14,
          color: Color(0xDEFFFFFF))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.14,
          color: Color(0xDEFFFFFF));
  TextStyle? get checkoutAsset => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.regular,
          letterSpacing: 0.5,
          color: Color(0xDE000000));
  TextStyle? get checkoutSubAsset => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.25,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.bold,
          letterSpacing: 0.25,
          color: Color(0x99000000));
  TextStyle? get checkoutItem => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0x99000000));
  TextStyle? get checkoutFees => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 12.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.4,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 12.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.4,
          color: Color(0xDE000000));
  TextStyle? get checkoutFee => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0x99000000))
      : TextStyle(
          fontSize: 14.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.25,
          color: Color(0x99000000));
  TextStyle? get checkoutTotal => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000));
  TextStyle? get switchText => this.brightness == Brightness.light
      ? TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000))
      : TextStyle(
          fontSize: 16.0,
          fontFamily: 'Nunito',
          fontWeight: FontWeights.semiBold,
          letterSpacing: 0.5,
          color: Color(0xDE000000));
}
