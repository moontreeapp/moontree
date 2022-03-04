import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/theme/extensions.dart';

enum UserLevel { beginner, intermediate, advanced }

class Advanced extends StatefulWidget {
  @override
  State createState() => new _AdvancedState();
}

class _AdvancedState extends State<Advanced> {
  late UserLevel? chosenLevel = UserLevel.beginner;

  @override
  void initState() {
    super.initState();
    //chosenLevel = res.settings.primaryIndex.getOne(SettingName.User_Level)!.value
    chosenLevel = chosenLevel ?? UserLevel.beginner;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: <Widget>[
        RadioListTile<UserLevel>(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.all(0),
            activeColor: Color(0xFF5C6BC0),
            value: UserLevel.beginner,
            groupValue: chosenLevel,
            title: Text(
              'Beginner (Recommended)',
              style: Theme.of(context).userLevel,
            ),
            onChanged: (value) /*async*/ {
              //await res.settings.save(Setting(
              //    name: SettingName.Send_Immediate,
              //    value: !res.settings.primaryIndex
              //        .getOne(SettingName.Send_Immediate)!
              //        .value));
              setState(() {
                chosenLevel = value!;
              });
            }),
        RadioListTile<UserLevel>(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.all(0),
            activeColor: Color(0xFF5C6BC0),
            value: UserLevel.intermediate,
            groupValue: chosenLevel,
            title: Text('Intermediate', style: Theme.of(context).userLevel),
            onChanged: (value) {
              setState(() {
                chosenLevel = value!;
              });
            }),
        RadioListTile<UserLevel>(
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.all(0),
            activeColor: Color(0xFF5C6BC0),
            value: UserLevel.advanced,
            groupValue: chosenLevel,
            title: Text('Advanced', style: Theme.of(context).userLevel),
            onChanged: (value) {
              setState(() {
                chosenLevel = value!;
              });
            }),
      ],
    );
  }
}
