import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo/moontree_logo.png',
                    height: 128.figma(context),
                  ),
                  GestureDetector(
                    onTap: () {
                      launch('https://twitter.com/moontreewallet');
                    },
                    child: Text(
                      '@moontreewallet',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ]),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'v1.0.0-alpha+1~1',
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: AppColors.black60,
                        fontWeight: FontWeights.semiBold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '© 2022 Moontree, LLC',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: AppColors.black60),
                  ),
                  SizedBox(height: 40),
                ]),
          ],
        )));
  }
}
