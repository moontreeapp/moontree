import 'package:flutter/material.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/components/buttons.dart';

AppBar header(context) => AppBar(
    leading: RavenButton().back(context),
    elevation: 2,
    centerTitle: false,
    title: RavenText('About').h2);

Center body(context) => Center(
      child: Column(
        children: <Widget>[
          Image(image: AssetImage('assets/ravenhead.png')),
          Text('Github.com/moontreeapp'),
          Text('MoonTreeLLC 2021'),
        ],
      ),
    );
