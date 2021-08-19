import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) => AppBar(
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: RavenText('Language Settings').h2);

SettingsList body(context) => SettingsList(sections: [
      SettingsSection(tiles: [
        SettingsTile(
            title: 'English',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
        SettingsTile(
            title: 'Chinese',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
        SettingsTile(
            title: 'Cesky',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
        SettingsTile(
            title: 'Espanol',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
        SettingsTile(
            title: 'Portugues',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
        SettingsTile(
            title: 'Thai',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
        SettingsTile(
            title: 'Turkce',
            leading: Icon(Icons.speaker),
            onPressed: (BuildContext context) {
              // toggle
            }),
      ])
    ]);
