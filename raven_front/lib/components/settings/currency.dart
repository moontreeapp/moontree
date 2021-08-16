import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: Colors.blue[900],
    leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[100]),
        onPressed: () => Navigator.pop(context)),
    elevation: 2,
    centerTitle: false,
    title: Text('Currency Settings',
        style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
  );
}

SettingsList body(context) {
  return SettingsList(
    sections: [
      SettingsSection(
        tiles: [
          SettingsTile(
            title: 'USD',
            leading: Icon(Icons.money),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'EUR',
            leading: Icon(Icons.euro),
            onPressed: (BuildContext context) {},
          ),
          SettingsTile(
            title: 'CAD',
            leading: Icon(Icons.money),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'GBP',
            leading: Icon(Icons.money),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'JPY',
            leading: Icon(Icons.money),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'NZD',
            leading: Icon(Icons.money),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'RUB',
            leading: Icon(Icons.money),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
        ],
      ),
    ],
  );
}
