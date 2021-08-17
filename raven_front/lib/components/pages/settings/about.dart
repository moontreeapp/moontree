import 'package:flutter/material.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) {
  return AppBar(
    backgroundColor: RavenColor().appBar,
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: Text('About', style: RavenTextStyle().h2),
  );
}

Center body(context) {
  return Center(
    child: Column(
      children: <Widget>[
        Image(image: AssetImage('assets/ravenhead.png')),
        Text('Github.com/moontreeapp'),
        Text('MoonTreeLLC 2021'),
      ],
    ),
  );
}
