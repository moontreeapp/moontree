import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:moontree_utils/moontree_utils.dart' show Concept;
import 'package:wallet_utils/wallet_utils.dart'
    show FeeRate, standardFee, cheapFee, fastFee;
import 'package:ravencoin_front/theme/colors.dart';

enum FeeOption {
  fast,
  standard,
  slow,
}

class FeeConcept extends Concept<FeeOption> {
  const FeeConcept({
    required FeeOption option,
    required this.iconData,
    required this.feeRate,
  }) : super(option);
  final IconData iconData;
  final FeeRate feeRate;
  Icon get icon => Icon(iconData, color: AppColors.primary);
  Icon iconFrom(double? size, Color? color, String? semanticLabel,
          TextDirection? textDirection, List<Shadow>? shadows) =>
      Icon(iconData,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
          textDirection: textDirection,
          shadows: shadows);
}

const FeeConcept fast = FeeConcept(
  option: FeeOption.fast,
  iconData: MdiIcons.speedometer,
  feeRate: fastFee,
);
const FeeConcept standard = FeeConcept(
  option: FeeOption.standard,
  iconData: MdiIcons.speedometerMedium,
  feeRate: standardFee,
);
const FeeConcept slow = FeeConcept(
  option: FeeOption.slow,
  iconData: MdiIcons.speedometerSlow,
  feeRate: cheapFee,
);
