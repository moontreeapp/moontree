import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';

class DecorationComponents {
  DecorationComponents();

  InputDecoration textFeild(
    BuildContext context, {
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? suffixIcon,
    String? suffixText,
    TextStyle? helperStyle,
    TextStyle? suffixStyle,
    FocusNode? focusNode,
  }) =>
      InputDecoration(
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.error, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.error, width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.primary, width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.black12)),
        labelStyle: Theme.of(context).textTheme.subtitle1,
        alignLabelWithHint: true,
        errorStyle: Theme.of(context).textFieldError,
        floatingLabelStyle: labelColor(focusNode, errorText),
        contentPadding: EdgeInsets.only(left: 16.5, top: 18, bottom: 16),
        labelText: labelText,
        hintText: hintText,
        helperText: getHelperText(focusNode, helperText),
        // takes precedence -- only fill on field valdiation failure:
        errorText: errorText,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        suffixStyle: suffixStyle,
        helperStyle: helperStyle ??
            Theme.of(context)
                .textTheme
                .caption!
                .copyWith(height: .7, color: AppColors.primary),
      );

  static TextStyle labelColor(FocusNode? focusNode, String? errorText) {
    return focusNode != null
        ? focusNode.hasFocus
            ? TextStyle(
                color: errorText == null ? AppColors.primary : AppColors.error)
            : TextStyle(
                color: errorText == null ? AppColors.black60 : AppColors.error)
        : TextStyle(
            color: errorText == null ? AppColors.black60 : AppColors.error);
  }

  static String? getHelperText(FocusNode? focusNode, String? helperText) {
    return focusNode != null
        ? focusNode.hasFocus
            ? helperText
            : null
        : helperText;
  }
}
