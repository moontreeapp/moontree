import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/buttons.dart';

class Currency extends StatefulWidget {
  final dynamic data;
  const Currency({this.data}) : super();

  @override
  _CurrencyState createState() => _CurrencyState();
}

class _CurrencyState extends State<Currency> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
        leading: RavenButton.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text('Currency Settings'),
      );

  SettingsList body() => SettingsList(sections: [
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
