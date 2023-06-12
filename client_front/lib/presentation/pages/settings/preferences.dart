import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/front/choices/switch_choice.dart';

class Preferences extends StatelessWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SwtichChoice(
          label: 'Show Full Asset Names',
          description:
              'Assets can have long names such as MOONTREE/SUBASSET. Toggle on to show full asset names.',
          hideDescription: true,
          initial: pros.settings.fullAssetsShown,
          onChanged: (bool value) => pros.settings.showFullAssets(value),
        )
      ],
    );
  }
}
