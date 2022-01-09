import 'package:flutter/material.dart';
import 'package:raven_front/widgets/widgets.dart';

class ImportExport extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SettingItems(names: [
        UISettingName.Import,
        UISettingName.Export,
      ]);
}
