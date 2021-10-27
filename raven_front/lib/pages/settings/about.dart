import 'package:flutter/material.dart';

import 'package:raven_mobile/components/components.dart';
import 'package:raven_mobile/utils/utils.dart';

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
    data = populateData(context, data);
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
      leading: components.buttons.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('About'));

  Center body() => Center(
        child: Column(
          children: <Widget>[
            Image(image: AssetImage('assets/rvn.png')),
            Text('Github.com/moontreeapp'),
            Text('MoonTreeLLC 2021'),
          ],
        ),
      );
}
