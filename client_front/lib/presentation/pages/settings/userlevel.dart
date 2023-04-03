import 'package:flutter/material.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

enum UserLevel { beginner, intermediate, advanced }

class Advanced extends StatefulWidget {
  const Advanced({Key? key}) : super(key: key);

  @override
  State createState() => _AdvancedState();
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
        back: const BlankBack(),
        front: FrontCurve(
            child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            RadioListTile<UserLevel>(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                value: UserLevel.beginner,
                groupValue: chosenLevel,
                title: Text(
                  'Beginner (Recommended)',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onChanged: (UserLevel? value) /*async*/ {
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
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                value: UserLevel.intermediate,
                groupValue: chosenLevel,
                title: Text('Intermediate',
                    style: Theme.of(context).textTheme.bodyText1),
                onChanged: (UserLevel? value) {
                  setState(() {
                    chosenLevel = value;
                  });
                }),
            RadioListTile<UserLevel>(
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                value: UserLevel.advanced,
                groupValue: chosenLevel,
                title: Text('Advanced',
                    style: Theme.of(context).textTheme.bodyText1),
                onChanged: (UserLevel? value) {
                  setState(() {
                    chosenLevel = value;
                  });
                }),
          ],
        )));
  }
}
