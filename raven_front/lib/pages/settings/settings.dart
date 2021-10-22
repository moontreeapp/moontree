import 'package:flutter/material.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:reservoir/reservoir.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';
import 'package:raven/utils/database.dart' as ravenDatabase;
import 'package:raven/raven.dart';

class Settings extends StatefulWidget {
  final dynamic data;
  const Settings({this.data}) : super();

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
      title: Text('Settings'));

  SettingsList body() => SettingsList(
        sections: [
          SettingsSection(tiles: [
            SettingsTile(
                title: 'Account',
                subtitle: Current.account.name,
                leading: Icon(Icons.account_balance_wallet_rounded),
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/account')),
            SettingsTile(
                title: 'Accounts Overview',
                leading: Icon(Icons.lightbulb),
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/technical')),
            SettingsTile(
                title: 'P2P Exchange',
                enabled: false,
                leading: Icon(Icons.swap_horiz),
                onPressed: (BuildContext context) {})
          ]),
          SettingsSection(
            title: 'App',
            tiles: [
              SettingsTile(
                  title: 'Password',
                  leading: Icon(Icons.password),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/password/change')),
              SettingsTile(
                  title: 'Network',
                  leading: Icon(Icons.network_check),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/network')),
              SettingsTile(
                  title: 'Currency',
                  leading: Icon(Icons.money),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/currency')),
              SettingsTile(
                  title: 'Language',
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/language')),
              SettingsTile(
                  title: 'About',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/about')),
              SettingsTile(
                  title: 'Print Histories',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) {
                    for (var item in transactions.data) {
                      print(item);
                    }
                  }),
              SettingsTile(
                  title: 'Clear Database',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) {
                    ravenDatabase.deleteDatabase();
                  }),
              SettingsTile(
                  title: 'show data',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) {
                    print(services.password.required);
                    print(services.cipher.latestCipherType);
                    print(services.cipher.currentCipherUpdate);
                  }),
              //SettingsTile(
              //    title: 'cipher registry',
              //    leading: Icon(Icons.info_outline_rounded),
              //    onPressed: (BuildContext context) {
              //      print(cipherRegistry.ciphers);
              //    }),
              //SettingsTile.switchTile(
              //  title: 'Use fingerprint',
              //  leading: Icon(Icons.fingerprint),
              //  switchValue: true,
              //  onToggle: (bool value) {},
              //),
            ],
          ),
        ],
      );
}
