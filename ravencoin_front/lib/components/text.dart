import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/components/components.dart';

class TextComponents {
  TextComponents();

  Widget get passwordWarning => Text(
        'Your password cannot be recovered.\nDo not forget your password.',
        textAlign: TextAlign.center,
        style: Theme.of(components.navigator.routeContext!)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      );
}
