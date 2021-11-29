import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: components.headers.back(context, 'Account Settings'),
        body: SettingsList(sections: [SettingsSection(tiles: [])]));
  }
}
