import 'package:flutter/material.dart';
import 'package:raven_front/utils/size.dart';

extension RelativeHeightDoble on double {
  double relative(BuildContext context) => relativeHeight(context, this);
}

extension RelativeHeightInt on int {
  double relative(BuildContext context) => relativeHeight(context, this);
}
