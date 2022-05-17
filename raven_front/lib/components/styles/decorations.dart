import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class DecorationComponents {
  DecorationComponents();

  /// superceded by TextFieldFormatted widget which has this built in.
  InputDecoration textField(
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
    bool alwaysShowHelper = false,
    bool enabled = true, // be sure to set the field to enabled: false
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
        disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: AppColors.black12)),
        labelStyle: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: enabled ? null : AppColors.black38),
        alignLabelWithHint: true,
        floatingLabelStyle: labelColor(focusNode, errorText),
        contentPadding: EdgeInsets.only(left: 16.5, top: 18, bottom: 16),
        labelText: labelText,
        hintText: hintText,
        helperText: getHelperText(focusNode, helperText, alwaysShowHelper),
        // takes precedence -- only fill on field valdiation failure:
        errorText: errorText,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        suffixStyle: suffixStyle,
        errorStyle: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(height: .8, color: AppColors.error),
        helperStyle: helperStyle ??
            Theme.of(context)
                .textTheme
                .caption!
                .copyWith(height: .8, color: AppColors.primary),
      );

  TextStyle labelColor(FocusNode? focusNode, String? errorText) {
    /// to fix #594 I think you'd have to do something like add a listener on
    /// this foucsNode to rebuild this or the parent widget when it gains focus,
    /// you want the click to redraw the text, otherwise it stays black60...
    /// I tested that and wasn't able to get it to work...
    return focusNode?.hasFocus ?? false
        ? TextStyle(
            color: errorText == null ? AppColors.error : AppColors.error)
        : TextStyle(
            color: errorText == null ? AppColors.black60 : AppColors.error);
  }

  static String? getHelperText(
    FocusNode? focusNode,
    String? helperText, [
    bool alwaysShowHelper = false,
  ]) {
    return alwaysShowHelper
        ? helperText
        : focusNode != null
            ? focusNode.hasFocus
                ? helperText
                : null
            : helperText;
  }
}
