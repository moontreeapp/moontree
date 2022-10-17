import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

enum DeveloperModeChoices {
  on,
  off,
}

class DeveloperModeChoice extends StatefulWidget {
  final dynamic data;
  const DeveloperModeChoice({this.data}) : super();

  @override
  _DeveloperModeChoice createState() => _DeveloperModeChoice();
}

class _DeveloperModeChoice extends State<DeveloperModeChoice> {
  DeveloperModeChoices? devChoice = DeveloperModeChoices.off;

  @override
  void initState() {
    super.initState();
    devChoice = pros.settings.developerMode == true
        ? DeveloperModeChoices.on
        : DeveloperModeChoices.off;
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
        Text('Developer Mode', style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Developer Mode has some experimental functionality, use at your own risk. It is always best to make a paper backup first.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        RadioListTile<DeveloperModeChoices>(
          title: const Text('On'),
          value: DeveloperModeChoices.on,
          groupValue: devChoice,
          onChanged: (DeveloperModeChoices? value) => setState(() {
            if (value != null) {
              devChoice = value;
              pros.settings.toggleDevMode(true);
            }
          }),
        ),
        RadioListTile<DeveloperModeChoices>(
          title: const Text('Off'),
          value: DeveloperModeChoices.off,
          groupValue: devChoice,
          onChanged: (DeveloperModeChoices? value) => setState(() {
            if (value != null) {
              devChoice = value;
              pros.settings.toggleDevMode(false);
            }
          }),
        ),
      ],
    );
  }
}
