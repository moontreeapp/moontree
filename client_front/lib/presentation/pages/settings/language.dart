import 'package:flutter/material.dart';

class Language extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();

    /// no longer using settings_ui
    //return Scaffold(
    //appBar: components.headers.back(context, 'Language Settings'),
    //body: SettingsList(sections: [
    //  SettingsSection(tiles: [
    //    LanguageTile('English', enabled: true),
    //    LanguageTile('中文 (Chinese)'),
    //    LanguageTile('Český'),
    //    LanguageTile('Español'),
    //    LanguageTile('Português'),
    //    LanguageTile('ภาษาไทย (Thai)'),
    //    LanguageTile('Türkçe')
    //  ])
    //]),
    //);
  }
}

//class LanguageTile extends SettingsTile {
//  LanguageTile(
//    language, {
//    icon = Icons.speaker,
//    enabled = false,
//  }) : super(
//            title: language,
//            enabled: enabled,
//            leading: Icon(icon),
//            onPressed: (BuildContext context) {});
//}
//