import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ravencoin_front/concepts/concept.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show FeeRate, standardFee, cheapFee, fastFee;

enum FeeOption {
  fast,
  standard,
  slow,
}

class _FeeConcept extends Concept<FeeOption> {
  final IconData iconData;
  final FeeRate feeRate;
  const _FeeConcept({
    required FeeOption option,
    required this.iconData,
    required this.feeRate,
  }) : super(option);
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

class fees {
  static const fast = _FeeConcept(
    option: FeeOption.fast,
    iconData: MdiIcons.speedometer,
    feeRate: fastFee,
  );
  static const standard = _FeeConcept(
    option: FeeOption.standard,
    iconData: MdiIcons.speedometerMedium,
    feeRate: standardFee,
  );
  static const slow = _FeeConcept(
    option: FeeOption.slow,
    iconData: MdiIcons.speedometerSlow,
    feeRate: cheapFee,
  );
}
