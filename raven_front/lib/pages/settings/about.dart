import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/settings/about.dart' as about;
import 'package:raven_mobile/styles.dart';

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
    return Scaffold(appBar: about.header(context), body: about.body(context));
  }
}
