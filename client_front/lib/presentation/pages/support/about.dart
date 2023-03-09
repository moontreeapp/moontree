import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          GestureDetector(
              onDoubleTap: () =>
                  clicked ? sail.to('/settings/advanced') : clicked = true,
              child: Image.asset(
                'assets/logo/moontree_logo.png',
                height: null,
              )),
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://twitter.com/moontreewallet'));
            },
            child: Text(
              '@moontreewallet',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: AppColors.primary),
            ),
          ),
        ],
        firstLowerChildren: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$VERSION_TRACK: ' +
                      services.version
                          .byPlatform(Platform.isIOS ? 'ios' : 'android'),
                  style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      color: AppColors.black60,
                      fontWeight: FontWeights.semiBold),
                ),
                //const SizedBox(height: 8),

                //const SizedBox(height: 40),
              ]),
        ],
        secondLowerChildren: <Widget>[
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  '© 2022 Moontree, LLC',
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: AppColors.black60),
                )
              ]),
        ]);
  }
}
