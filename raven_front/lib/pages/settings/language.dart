import 'package:flutter/material.dart';

import 'package:raven_mobile/components/settings/language.dart' as language;

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
    Color? bgColor = Colors.blueAccent[50];
    return Scaffold(
        backgroundColor: bgColor,
        appBar: language.header(context),
        body: language.body(context));
  }
}
