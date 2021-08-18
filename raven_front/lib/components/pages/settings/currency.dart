import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: RavenColor().appBar,
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: Text('Currency Settings', style: RavenTextStyle().h2),
  );
}

SettingsList body(context) {
  return SettingsList(sections: [
    SettingsSection(tiles: [
      SettingsTile(
          title: 'USD',
          leading: Icon(Icons.money),
          onPressed: (BuildContext context) {
            // toggle
          }),
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
          }),
      SettingsTile(
          title: 'GBP',
          leading: Icon(Icons.money),
          onPressed: (BuildContext context) {
            // toggle
          }),
      SettingsTile(
          title: 'JPY',
          leading: Icon(Icons.money),
          onPressed: (BuildContext context) {
            // toggle
          }),
      SettingsTile(
          title: 'NZD',
          leading: Icon(Icons.money),
          onPressed: (BuildContext context) {
            // toggle
          }),
      SettingsTile(
          title: 'RUB',
          leading: Icon(Icons.money),
          onPressed: (BuildContext context) {
            // toggle
          }),
    ])
  ]);
}
