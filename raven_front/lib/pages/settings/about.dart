import 'package:flutter/material.dart';

import 'package:raven_mobile/components/components.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: components.headers.back(context, 'About'),
      body: body(),
    );
  }

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
