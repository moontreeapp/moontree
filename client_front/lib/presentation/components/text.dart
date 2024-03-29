import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class TextComponents {
  const TextComponents();

  Widget get passwordWarning => Text(
        'Your password cannot be recovered.\nDo not forget your password.',
        textAlign: TextAlign.center,
        style: Theme.of(components.routes.context!)
            .textTheme
            .titleMedium!
            .copyWith(color: AppColors.error),
      );
}
