import 'package:flutter/material.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_front/theme/extensions.dart';

enum SecurityOption { none, system_default, password }

class Security extends StatefulWidget {
  @override
  State createState() => new _SecurityState();
}

class _SecurityState extends State<Security> {
  SecurityOption? securityChoice;
  bool hasPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      style: !hasPassword
                          ? Theme.of(context).securityDisabled
                          : Theme.of(context).securityDestination),
                  value: SecurityOption.none,
                  groupValue: securityChoice,
                  onChanged: !hasPassword
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
                      SecurityOption.system_default.enumString
                          .toTitleCase(underscoreAsSpace: true),
                      style: !hasPassword
                          ? Theme.of(context).securityDisabled
                          : Theme.of(context).securityDestination),
                  value: SecurityOption.system_default,
                  groupValue: securityChoice,
                  onChanged: !hasPassword
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
                      style: hasPassword
                          ? Theme.of(context).securityDestination
                          : Theme.of(context).securityDestination),
                  value: SecurityOption.password,
                  groupValue: securityChoice,
                  onChanged: hasPassword
                      ? null
                      : (SecurityOption? value) {
                          setState(() {
                            securityChoice = value;
                          });
                        },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 40, left: 16, right: 16),
              child: Column(

                  // The crossAxisAlignment is needed to give content height > 0
                  //   - we are in a Row, so crossAxis is Column, so this enforces
                  //     to "stretch height".
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_buildBehavior()]),
            )
          ],
        ));
  }

  Widget _buildBehavior() => {
        SecurityOption.none: _buildBehavior1,
        SecurityOption.system_default: _buildBehavior1,
        SecurityOption.password: _buildBehavior1,
        null: _buildBehavior1,
      }[securityChoice]!();

  Widget _buildBehavior1() => Container(
      height: 40,
      child: OutlinedButton.icon(
          onPressed: () {/*navigate to set, change or other screens*/},
          icon: Icon(Icons.lock_rounded),
          label: Text('CHANGE'.toUpperCase()),
          style: ButtonStyle(
            textStyle:
                MaterialStateProperty.all(Theme.of(context).navBarButton),
            foregroundColor: MaterialStateProperty.all(Color(0xDE000000)),
            side: MaterialStateProperty.all(BorderSide(
                color: Theme.of(context).backgroundColor,
                width: 2,
                style: BorderStyle.solid)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0))),
          )));
}
