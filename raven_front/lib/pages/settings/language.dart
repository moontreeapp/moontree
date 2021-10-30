import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/indicators/indicators.dart';
import 'package:raven_mobile/utils/utils.dart';

class Language extends StatefulWidget {
  final dynamic data;
  const Language({this.data}) : super();

  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
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
        title: Text('Language Settings'),
        actions: [
          indicators.process,
          indicators.client,
        ],
      );

  SettingsList body() => SettingsList(sections: [
        SettingsSection(tiles: [
          SettingsTile(
              title: 'English',
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'Chinese',
              enabled: false,
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'Cesky',
              enabled: false,
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'Espanol',
              enabled: false,
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'Portugues',
              enabled: false,
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'Thai',
              enabled: false,
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
          SettingsTile(
              title: 'Turkce',
              enabled: false,
              leading: Icon(Icons.speaker),
              onPressed: (BuildContext context) {}),
        ])
      ]);
}
