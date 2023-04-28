import 'package:flutter/material.dart';

const BorderRadius topRoundedBorder8 = BorderRadius.only(
  topLeft: Radius.circular(8),
  topRight: Radius.circular(8),
);
const BorderRadius topRoundedBorder16 = BorderRadius.only(
  topLeft: Radius.circular(16),
  topRight: Radius.circular(16),
);
BorderRadius topRoundedBorder(double value) => BorderRadius.only(
      topLeft: Radius.circular(value),
      topRight: Radius.circular(value),
    );
const RoundedRectangleBorder rounded8 = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)));
const RoundedRectangleBorder topRounded8 =
    RoundedRectangleBorder(borderRadius: topRoundedBorder8);
const RoundedRectangleBorder topRounded16 =
    RoundedRectangleBorder(borderRadius: topRoundedBorder16);
