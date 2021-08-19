import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/settings/settings.dart'
    as settings;
import 'package:raven_mobile/styles.dart';

class Settings extends StatefulWidget {
  final dynamic data;
  const Settings({this.data}) : super();

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
        appBar: settings.header(context), body: settings.body(context));
  }
}
