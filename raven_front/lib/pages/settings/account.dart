import 'package:flutter/material.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:settings_ui/settings_ui.dart';

class AccountSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: components.headers.back(context, 'Account Settings'),
        body: SettingsList(sections: [
          SettingsSection(tiles: [
            SettingsTile(
                title: 'Import Wallet',
                leading: components.icons.import,
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/import')),
            SettingsTile(
                title: 'Export Account',
                leading: components.icons.export,
                onPressed: (BuildContext context) => Navigator.pushNamed(
                    context, '/settings/export',
                    arguments: {'accountId': 'current'})),
            SettingsTile(
                title: 'Sign Message',
                enabled: false,
                leading: Icon(Icons.fact_check_sharp),
                onPressed: (BuildContext context) {
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ...()),
                  //);
                })
          ])
        ]));
  }
}
