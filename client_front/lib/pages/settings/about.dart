import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:client_front/theme/theme.dart';
import 'package:client_front/utils/extensions.dart';
import 'package:client_front/widgets/widgets.dart';
import 'package:client_back/client_back.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  bool up = false;
  bool down = false;
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: const BlankBack(),
        front: FrontCurve(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                      onVerticalDragEnd: (DragEndDetails x) async {
                        if (x.velocity.pixelsPerSecond.dy < -500) {
                          up = true;
                        }
                        if (x.velocity.pixelsPerSecond.dy > 500) {
                          down = true;
                        }
                      },
                      onDoubleTap: () => (up && down) || clicked
                          ? Navigator.of(context)
                              .pushReplacementNamed('/settings/advanced')
                          : clicked = true,
                      child: Image.asset(
                        'assets/logo/moontree_logo.png',
                        height: 128.figma(context),
                      )),
                  GestureDetector(
                    onTap: () {
                      launchUrl(
                          Uri.parse('https://twitter.com/moontreewallet'));
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
                    '$VERSION_TRACK: ' +
                        services.version
                            .byPlatform(Platform.isIOS ? 'ios' : 'android'),
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                        color: AppColors.black60,
                        fontWeight: FontWeights.semiBold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2022 Moontree, LLC',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(color: AppColors.black60),
                  ),
                  const SizedBox(height: 40),
                ]),
          ],
        )));
  }
}
