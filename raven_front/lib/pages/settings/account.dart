import 'package:flutter/material.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';

class AccountSettings extends StatefulWidget {
  final dynamic data;
  const AccountSettings({this.data}) : super();

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
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
      title: Text('Account Settings'));

  SettingsList body() => SettingsList(sections: [
        SettingsSection(tiles: [
          SettingsTile(
              title: 'Import Wallet',
              leading: RavenIcon.import,
              onPressed: (BuildContext context) =>
                  Navigator.pushNamed(context, '/settings/import')),
          SettingsTile(
              title: 'Export Account',
              leading: RavenIcon.export,
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
      ]);
}
