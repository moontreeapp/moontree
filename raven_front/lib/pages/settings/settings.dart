import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/ipfs.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: components.headers.back(context, 'Settings'),
      body: SettingsList(
        contentPadding: EdgeInsets.only(top: 10),
        sections: [
          SettingsSection(title: 'Wallet', tiles: [
            SettingsTile(
                title: 'Import',
                leading: components.icons.import,
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/import')),
            SettingsTile(
                title: 'Export (Backup)',
                leading: components.icons.export,
                onPressed: (BuildContext context) => Navigator.pushNamed(
                    context, '/settings/export',
                    arguments: {'accountId': 'current'})),
            /*
            SettingsTile(
                title: 'Sign Message',
                enabled: false,
                leading: Icon(Icons.fact_check_sharp),
                onPressed: (BuildContext context) {
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ...()),
                  //);
                }),
            */
            SettingsTile(
                title: 'Accounts Overview',
                leading: Icon(Icons.lightbulb),
                onPressed: (BuildContext context) =>
                    Navigator.pushNamed(context, '/settings/technical')),
            /* Coming soon!
            SettingsTile(
                title: 'P2P Exchange',
                enabled: false,
                leading: Icon(Icons.swap_horiz),
                onPressed: (BuildContext context) {})
            */
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
              /*
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
              */
              SettingsTile(
                  title: 'About',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/about')),
/*                      
              SettingsTile(
                  title: 'Clear Database',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) {
                    ravenDatabase.deleteDatabase();
                  }),
              SettingsTile(
                  title: 'show data',
                  leading: Icon(Icons.info_outline_rounded),
                  onPressed: (BuildContext context) async {}),
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
