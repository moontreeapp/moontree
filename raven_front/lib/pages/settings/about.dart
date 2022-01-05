import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 40),
        Image.asset('assets/logo/moontree_logo_56.png'),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '© 2022 Moontree, LLC',
                style: Theme.of(context).copyright,
              ),
              SizedBox(height: 40),
            ]),
      ],
    );
  }
}
