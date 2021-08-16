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
    title: Text('Language Settings',
        style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
  );
}

SettingsList body(context) {
  return SettingsList(
    sections: [
      SettingsSection(
        tiles: [
          SettingsTile(
            title: 'English',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'Chinese',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'Cesky',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'Espanol',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'Portugues',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'Thai',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
          SettingsTile(
            title: 'Turkce',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            },
          ),
        ],
      ),
    ],
  );
}
