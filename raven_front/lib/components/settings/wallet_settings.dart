import 'package:flutter/material.dart';
import 'package:raven_mobile/pages/settings/export.dart';
import 'package:raven_mobile/pages/settings/import.dart';
import 'package:settings_ui/settings_ui.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: Colors.blue[900],
    leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[100]),
        onPressed: () => Navigator.pop(context)),
    elevation: 2,
    centerTitle: false,
    title: Text('Wallet Settings',
        style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
  );
}

SettingsList body(context) {
  return SettingsList(
    sections: [
      SettingsSection(
        tiles: [
          SettingsTile(
            title: 'Import Wallet',
            leading: Icon(Icons.account_balance_wallet_rounded),
            onPressed: (BuildContext context) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Import()),
              );
            },
          ),
          SettingsTile(
            title: 'Export/Backup Wallet',
            leading: Icon(Icons.swap_horiz),
            onPressed: (BuildContext context) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Export()),
              );
            },
          ),
          SettingsTile(
            title: 'Sign Message',
            enabled: false,
            leading: Icon(Icons.swap_horiz),
            onPressed: (BuildContext context) {
              //Navigator.push(
              //  context,
              //  MaterialPageRoute(builder: (context) => ...()),
              //);
            },
          ),
        ],
      ),
    ],
  );
}
