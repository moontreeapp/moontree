import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/widgets/widgets.dart';

enum SecurityOption { none, system_default, password }

class Security extends StatefulWidget {
  @override
  State createState() => new _SecurityState();
}

class _SecurityState extends State<Security> {
  SecurityOption? securityChoice;

  @override
  void initState() {
    super.initState();
    securityChoice = services.password.required
        ? SecurityOption.password
        : SecurityOption.none;
  }

  @override
  Widget build(BuildContext context) => BackdropLayers(
      back: BlankBack(),
      front: FrontCurve(
          child: Padding(
              padding: EdgeInsets.only(top: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      RadioListTile<SecurityOption>(
                        activeColor: Theme.of(context).backgroundColor,
                        title: Text(
                            SecurityOption.none.enumString
                                .toTitleCase(underscoresAsSpace: true),
                            style: Theme.of(context).textTheme.bodyText1),
                        value: SecurityOption.none,
                        groupValue: securityChoice,
                        onChanged: (SecurityOption? value) =>
                            services.password.required
                                ? behaviorRemovePassword()
                                : () {/* do nothing*/}(),
                      ),
                      RadioListTile<SecurityOption>(
                        activeColor: Theme.of(context).backgroundColor,
                        title: Text(
                            SecurityOption.password.enumString
                                .toTitleCase(underscoresAsSpace: true),
                            style: Theme.of(context).textTheme.bodyText1),
                        value: SecurityOption.password,
                        groupValue: securityChoice,
                        onChanged: (SecurityOption? value) => services
                                .password.required
                            ? behaviorChangePassword() // never gets triggered. use button
                            : behaviorSetPassword(),
                      ),
                    ],
                  ),
                  ...[
                    if (securityChoice == SecurityOption.password &&
                        services.password.required)
                      components.containers.navBar(context,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                components.buttons.actionButton(
                                  context,
                                  onPressed: behaviorChangePassword,
                                  label: 'Change'.toUpperCase(),
                                )
                              ]))
                  ]
                ],
              ))));

  void behaviorSetPassword() {
    streams.app.verify.add(true);
    Navigator.of(context).pushNamed('/security/change');
  }

  void behaviorChangePassword() {
    if (services.cipher.canAskForPasswordNow) {
      streams.app.verify.add(false);
    }
    Navigator.of(context).pushNamed('/security/change');
  }

  void behaviorRemovePassword() {
    if (services.cipher.canAskForPasswordNow) {
      streams.app.verify.add(false);
    }
    Navigator.of(context).pushNamed('/security/remove');
  }
}
