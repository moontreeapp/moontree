import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/components/components.dart';

class TextComponents {
  TextComponents();

  Widget get passwordWarning => Text(
        'Your password cannot be recovered.\nDo not forget your password.',
        textAlign: TextAlign.center,
        style: Theme.of(components.routes.routeContext!)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      );
}
