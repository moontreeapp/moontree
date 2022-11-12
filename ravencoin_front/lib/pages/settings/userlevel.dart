import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

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
    //chosenLevel = pros.settings.primaryIndex.getOne(SettingName.User_Level)!.value
    chosenLevel = chosenLevel ?? UserLevel.beginner;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            RadioListTile<UserLevel>(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.all(0),
                activeColor: AppColors.primary,
                value: UserLevel.beginner,
                groupValue: chosenLevel,
                title: Text(
                  'Beginner (Recommended)',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onChanged: (value) /*async*/ {
                  //await pros.settings.save(Setting(
                  //    name: SettingName.Send_Immediate,
                  //    value: !pros.settings.primaryIndex
                  //        .getOne(SettingName.Send_Immediate)!
                  //        .value));
                  setState(() {
                    chosenLevel = value!;
                  });
                }),
            RadioListTile<UserLevel>(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.all(0),
                activeColor: AppColors.primary,
                value: UserLevel.intermediate,
                groupValue: chosenLevel,
                title: Text('Intermediate',
                    style: Theme.of(context).textTheme.bodyText1),
                onChanged: (value) {
                  setState(() {
                    chosenLevel = value!;
                  });
                }),
            RadioListTile<UserLevel>(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.all(0),
                activeColor: AppColors.primary,
                value: UserLevel.advanced,
                groupValue: chosenLevel,
                title: Text('Advanced',
                    style: Theme.of(context).textTheme.bodyText1),
                onChanged: (value) {
                  setState(() {
                    chosenLevel = value!;
                  });
                }),
          ],
        )));
  }
}
