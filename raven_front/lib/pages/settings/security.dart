import 'package:flutter/material.dart';
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
  bool hasPassword = false;
  String actionName = 'Set';

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
                    style: hasPassword
                        ? Theme.of(context).securityDisabled
                        : Theme.of(context).securityDestination),
                value: SecurityOption.none,
                groupValue: securityChoice,
                onChanged: hasPassword
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
                    style: true
                        ? Theme.of(context).securityDisabled
                        : Theme.of(context).securityDestination),
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
            padding: EdgeInsets.only(top: 40, bottom: 40, left: 16, right: 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [buildBehavior()]),
          )
        ],
      ));

  Widget buildBehavior() => {
        SecurityOption.none: {
          true: behaviorRemovePassword,
          false: behaviorSubmit,
        },
        SecurityOption.system_default: {
          true: behaviorSubmit,
          false: behaviorSubmit,
        },
        SecurityOption.password: {
          true: behaviorChangePassword,
          false: behaviorChangePassword,
        },
        null: {
          true: behaviorSubmit,
          false: behaviorSubmit,
        },
      }[securityChoice]![hasPassword]!();

  Widget behaviorSubmit() => behaviorBuilder(
        label: 'Submit',
        onPressed: () {/* do nothing*/},
        disabled: true,
      );

  Widget behaviorSetPassword() => behaviorBuilder(
        label: 'Set Password',
        onPressed: () {/*navigate to set password*/},
      );

  Widget behaviorChangePassword() => behaviorBuilder(
        label: 'Change',
        onPressed: () {/*navigate to change password*/},
      );

  Widget behaviorRemovePassword() => behaviorBuilder(
        label: 'Remove Password',
        onPressed: () {/*navigate to remove password*/},
      );

  Widget behaviorBuilder({
    required String label,
    required VoidCallback onPressed,
    bool disabled = false,
  }) =>
      Container(
          height: 40,
          child: OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                Icons.lock_rounded,
                color: disabled ? Color(0x61000000) : null,
              ),
              label: Text(
                label.toUpperCase(),
                style: disabled
                    ? Theme.of(context).navBarButtonDisabled
                    : Theme.of(context).navBarButton,
              ),
              style: components.styles.buttons.bottom(
                context,
                disabled: disabled,
              )));
}
