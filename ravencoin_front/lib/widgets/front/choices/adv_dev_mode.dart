import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

enum AdvancedDeveloperModeChoices {
  on,
  off,
}

class AdvancedDeveloperModeChoice extends StatefulWidget {
  final dynamic data;
  const AdvancedDeveloperModeChoice({this.data}) : super();

  @override
  _AdvancedDeveloperModeChoice createState() => _AdvancedDeveloperModeChoice();
}

class _AdvancedDeveloperModeChoice extends State<AdvancedDeveloperModeChoice> {
  AdvancedDeveloperModeChoices? devChoice = AdvancedDeveloperModeChoices.off;

  @override
  void initState() {
    super.initState();
    devChoice = pros.settings.advancedDeveloperMode == true
        ? AdvancedDeveloperModeChoices.on
        : AdvancedDeveloperModeChoices.off;
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
        Text('Advanced Developer Mode',
            style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Advanced Developer Mode has some extra experimental functionality, use at your own risk. It is always best to make a paper backup first.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        RadioListTile<AdvancedDeveloperModeChoices>(
          title: const Text('On'),
          value: AdvancedDeveloperModeChoices.on,
          groupValue: devChoice,
          onChanged: (AdvancedDeveloperModeChoices? value) => setState(() {
            if (value != null) {
              devChoice = value;
              pros.settings.toggleAdvDevMode(true);
            }
          }),
        ),
        RadioListTile<AdvancedDeveloperModeChoices>(
          title: const Text('Off'),
          value: AdvancedDeveloperModeChoices.off,
          groupValue: devChoice,
          onChanged: (AdvancedDeveloperModeChoices? value) => setState(() {
            if (value != null) {
              devChoice = value;
              pros.settings.toggleAdvDevMode(false);
            }
          }),
        ),
      ],
    );
  }
}
