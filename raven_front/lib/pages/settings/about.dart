import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 40),
            Image.asset(
              'assets/logo/moontree_logo.png',
              height: 72.ofMediaHeight(context),
            ),
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
        )));
  }
}
