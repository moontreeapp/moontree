import 'package:flutter/material.dart';
import 'package:raven_front/widgets/widgets.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SettingItems(names: [
        UISettingName.Security,
        UISettingName.User_Level,
        UISettingName.Network,
      ]);
}
