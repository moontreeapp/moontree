import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ravencoin_front/concepts/concepts.dart';

enum FeeOption {
  fast,
  standard,
  slow,
}

//class FeeConcept extends Concept {
//  final FeeOption option;
//  final IconData icon;
//  const FeeConcept({required this.option, required this.icon}) : super(option);
//}

class FeeConcept extends Concept<FeeOption> {
  final IconData icon;
  const FeeConcept({required option, required this.icon}) : super(option);
}

const fastFeeRate =
    FeeConcept(option: FeeOption.fast, icon: MdiIcons.speedometer);
const standardFeeRate =
    FeeConcept(option: FeeOption.standard, icon: MdiIcons.speedometerMedium);
const slowFeeRate =
    FeeConcept(option: FeeOption.slow, icon: MdiIcons.speedometerSlow);
