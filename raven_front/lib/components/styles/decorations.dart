import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';

class DecorationComponents {
  DecorationComponents();

  InputDecoration textFeild(
    BuildContext context, {
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
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
          floatingLabelStyle: TextStyle(color: const Color(0xFF5C6BC0)),
          contentPadding: EdgeInsets.only(left: 16.5, top: 18, bottom: 16),
          labelText: labelText,
          hintText: hintText,
          suffixIcon: suffixIcon);
}
