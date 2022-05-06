import 'package:flutter/material.dart';

class ShapeComponents {
  BorderRadius get topRoundedBorder8 => BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      );
  BorderRadius get topRoundedBorder16 => BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      );
  RoundedRectangleBorder get rounded8 => RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)));
  RoundedRectangleBorder get topRounded8 =>
      RoundedRectangleBorder(borderRadius: topRoundedBorder8);
  RoundedRectangleBorder get topRounded16 =>
      RoundedRectangleBorder(borderRadius: topRoundedBorder16);
}
