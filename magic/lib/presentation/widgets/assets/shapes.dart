import 'package:flutter/material.dart';

const BorderRadius topRoundedBorder8 = BorderRadius.only(
  topLeft: Radius.circular(8),
  topRight: Radius.circular(8),
);
const BorderRadius topRoundedBorder16 = BorderRadius.only(
  topLeft: Radius.circular(16),
  topRight: Radius.circular(16),
);
const BorderRadius bottomRoundedBorder16 = BorderRadius.only(
  bottomLeft: Radius.circular(16),
  bottomRight: Radius.circular(16),
);
const BorderRadius circularBorder = BorderRadius.all(Radius.circular(16.0));
BorderRadius topRoundedBorder(double value) => BorderRadius.only(
      topLeft: Radius.circular(value),
      topRight: Radius.circular(value),
    );
const RoundedRectangleBorder rounded8 = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8.0)));
const RoundedRectangleBorder rounded16 =
    RoundedRectangleBorder(borderRadius: circularBorder);
const RoundedRectangleBorder topRounded8 =
    RoundedRectangleBorder(borderRadius: topRoundedBorder8);
const RoundedRectangleBorder topRounded16 =
    RoundedRectangleBorder(borderRadius: topRoundedBorder16);
