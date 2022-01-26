import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

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
  Widget build(BuildContext context) => Padding(
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
                        .toTitleCase(underscoreAsSpace: true),
                    style: Theme.of(context).securityDestination),
                value: SecurityOption.none,
                groupValue: securityChoice,
                onChanged: (SecurityOption? value) => services.password.required
                    ? behaviorRemovePassword()
                    : () {/* do nothing*/}(),
              ),
              RadioListTile<SecurityOption>(
                activeColor: Theme.of(context).backgroundColor,
                title: Text(
                    SecurityOption.system_default.enumString
                        .toTitleCase(underscoreAsSpace: true),
                    style: services.password.required
                        ? Theme.of(context).securityDisabled
                        : Theme.of(context).securityDisabled),
                value: SecurityOption.system_default,
                groupValue: securityChoice,
                onChanged: true
                    ? null
                    : (SecurityOption? value) {
                        setState(() {
                          securityChoice = value;
                        });
                      },
              ),
              RadioListTile<SecurityOption>(
                activeColor: Theme.of(context).backgroundColor,
                title: Text(
                    SecurityOption.password.enumString
                        .toTitleCase(underscoreAsSpace: true),
                    style: Theme.of(context).securityDestination),
                value: SecurityOption.password,
                groupValue: securityChoice,
                onChanged: (SecurityOption? value) => services.password.required
                    ? behaviorChangePassword() // never gets triggered. use button
                    : behaviorSetPassword(),
              ),
            ],
          ),
          ...[
            if (securityChoice == SecurityOption.password &&
                services.password.required)
              Padding(
                padding:
                    EdgeInsets.only(top: 40, bottom: 40, left: 16, right: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          height: 40,
                          child: OutlinedButton.icon(
                              onPressed: behaviorChangePassword,
                              icon: Icon(
                                Icons.lock_rounded,
                              ),
                              label: Text(
                                'Change'.toUpperCase(),
                                style: Theme.of(context).navBarButton,
                              ),
                              style: components.styles.buttons.bottom(context)))
                    ]),
              )
          ]
        ],
      ));

  void behaviorSetPassword() {
    streams.app.verify.add(true);
    Navigator.of(context).pushNamed('/security/change');
  }

  void behaviorChangePassword() {
    streams.app.verify.add(false);
    Navigator.of(context).pushNamed('/security/change');
  }

  void behaviorRemovePassword() {
    streams.app.verify.add(false);
    Navigator.of(context).pushNamed('/security/remove');
  }
}
