import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_mobile/components/buttons.dart';

class WalletSettings extends StatefulWidget {
  final dynamic data;
  const WalletSettings({this.data}) : super();

  @override
  _WalletSettingsState createState() => _WalletSettingsState();
}

class _WalletSettingsState extends State<WalletSettings> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Wallet Settings'));

  SettingsList body() => SettingsList(sections: [
        SettingsSection(tiles: [
          SettingsTile(
              title: 'Import Wallet',
              leading: Icon(Icons.account_balance_wallet_rounded),
              onPressed: (BuildContext context) =>
                  Navigator.pushNamed(context, '/settings/import')),
          SettingsTile(
              title: 'Export/Backup Wallet',
              leading: Icon(Icons.swap_horiz),
              onPressed: (BuildContext context) =>
                  Navigator.pushNamed(context, '/settings/export')),
          SettingsTile(
              title: 'Technical View',
              leading: Icon(Icons.swap_horiz),
              onPressed: (BuildContext context) =>
                  Navigator.pushNamed(context, '/settings/technical')),
          SettingsTile(
              title: 'Sign Message',
              enabled: false,
              leading: Icon(Icons.swap_horiz),
              onPressed: (BuildContext context) {
                //Navigator.push(
                //  context,
                //  MaterialPageRoute(builder: (context) => ...()),
                //);
              })
        ])
      ]);
}
