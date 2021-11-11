import 'package:flutter/material.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/services/lookup.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven/utils/database.dart' as ravenDatabase;

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: components.headers.back(context, 'Settings'),
      body: SettingsList(
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
                  title: 'Clear Database',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) {
                    ravenDatabase.deleteDatabase();
                  }),
              SettingsTile(
                  title: 'show data',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) async {
                    //print(balances.data);
                    //print(securities.data);
                    1 / 0;
                    //print(vouts.byTransaction.getAll(
                    //    '4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240'));
                  }),
/*                      
*/
              //SettingsTile.switchTile(
              //  title: 'Use fingerprint',
              //  leading: Icon(Icons.fingerprint),
              //  switchValue: true,
              //  onToggle: (bool value) {},
              //),
            ],
          ),
        ],
      ),
    );
  }
}
