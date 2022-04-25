import 'package:flutter/material.dart';

class ShapeComponents {
  RoundedRectangleBorder get topRounded => RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.0),
        topRight: Radius.circular(8.0),
      ));
}
