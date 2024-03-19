import 'package:flutter/material.dart';
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/presentation/components/routes.dart';

const TextComponents text = TextComponents();

class TextComponents {
  const TextComponents();

  Widget get passwordWarning => Text(
        'Your password cannot be recovered.\nDo not forget your password.',
        textAlign: TextAlign.center,
        style: Theme.of(routes.context!)
            .textTheme
            .titleMedium!
            .copyWith(color: AppColors.error),
      );
}
