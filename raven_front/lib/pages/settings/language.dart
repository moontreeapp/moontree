import 'package:flutter/material.dart';

import 'package:settings_ui/settings_ui.dart';
import 'package:raven_mobile/components/buttons.dart';

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
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
      leading: RavenButton().back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Language Settings'));

  SettingsList body() => SettingsList(sections: [
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
}
