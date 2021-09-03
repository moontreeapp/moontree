import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';

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
    data = populateData(context, data);
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
              leading: Icon(Icons.add_box_outlined),
              onPressed: (BuildContext context) =>
                  Navigator.pushNamed(context, '/settings/import')),
          SettingsTile(
              title: 'Export/Backup Wallet',
              leading: Icon(Icons.save),
              onPressed: (BuildContext context) =>
                  Navigator.pushNamed(context, '/settings/export')),
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
      ]);
}
