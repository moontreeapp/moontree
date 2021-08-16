import 'package:flutter/material.dart';

import 'package:raven_mobile/components/settings/about.dart' as about;

class About extends StatefulWidget {
  final dynamic data;
  const About({this.data}) : super();

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
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
        appBar: about.header(context),
        body: about.body(context));
  }
}
