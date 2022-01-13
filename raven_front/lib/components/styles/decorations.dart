import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';

class DecorationComponents {
  DecorationComponents();

  InputDecoration textFeild(
    BuildContext context, {
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Color(0xFFAA2E25), width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Color(0xFFAA2E25), width: 2)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Color(0xFF5C6BC0), width: 2)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Color(0x1F000000))),
          labelStyle: Theme.of(context).sendFeildText,
          alignLabelWithHint: true,
          errorStyle: Theme.of(context).textFieldError,
          floatingLabelStyle: TextStyle(
              color: errorText == null
                  ? const Color(0xFF5C6BC0)
                  : const Color(0xFFAA2E25)),
          contentPadding: EdgeInsets.only(left: 16.5, top: 18, bottom: 16),
          labelText: labelText,
          hintText: hintText,
          // takes precedence -- only fill on field valdiation failure:
          errorText: errorText,
          suffixIcon: suffixIcon);
}
