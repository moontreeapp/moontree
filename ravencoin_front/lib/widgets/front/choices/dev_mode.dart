import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

class DeveloperModeChoice extends StatefulWidget {
  const DeveloperModeChoice() : super();

  @override
  _DeveloperModeChoice createState() => _DeveloperModeChoice();
}

class _DeveloperModeChoice extends State<DeveloperModeChoice> {
  late bool choice;

  @override
  void initState() {
    super.initState();
    choice = pros.settings.developerMode;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Developer Mode',
                style: Theme.of(context).textTheme.bodyText1),
            Switch(
                value: choice,
                onChanged: (value) {
                  pros.settings.toggleDevMode(value);
                  setState(() {
                    choice = value;
                  });
                }),
          ],
        ),
      ],
    );
  }
}
