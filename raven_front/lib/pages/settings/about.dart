import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 40),
        Container(
            height: 48,
            width: 48,
            child: Image.asset('assets/logo/moontree_logo.png')),
        Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '© 2022 Moontree, LLC',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1!
                    .copyWith(color: AppColors.black),
              ),
              SizedBox(height: 40),
            ]),
      ],
    );
  }
}
