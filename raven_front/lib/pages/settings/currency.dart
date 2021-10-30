import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';
import 'package:raven_mobile/utils/utils.dart';

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
    data = populateData(context, data);
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
        leading: components.buttons.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text('Currency Settings'),
        actions: [
          indicators.process,
          indicators.client,
        ],
      );

  SettingsList body() => SettingsList(sections: [
        SettingsSection(tiles: [
          SettingsTile(
              title: 'USD',
              leading: Icon(Icons.money),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'EUR',
              enabled: false,
              leading: Icon(Icons.euro),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'CAD',
              enabled: false,
              leading: Icon(Icons.money),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'GBP',
              enabled: false,
              leading: Icon(Icons.money),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'JPY',
              enabled: false,
              leading: Icon(Icons.money),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'NZD',
              enabled: false,
              leading: Icon(Icons.money),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'RUB',
              enabled: false,
              leading: Icon(Icons.money),
              onPressed: (BuildContext context) {}),
        ])
      ]);
}
