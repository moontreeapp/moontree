import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/settings/language.dart'
    as language;
import 'package:raven_mobile/styles.dart';

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
    return Scaffold(
        backgroundColor: RavenColor().background,
        appBar: language.header(context),
        body: language.body(context));
  }
}
