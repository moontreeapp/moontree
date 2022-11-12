import 'package:flutter/material.dart';

class SweepChoices extends StatefulWidget {
  final dynamic data;
  const SweepChoices({this.data}) : super();

  @override
  _SweepChoices createState() => _SweepChoices();
}

class _SweepChoices extends State<SweepChoices> {
  bool? sweepCurrency = true;
  bool? sweepAssets = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Sweep', style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Sweeping means moving all value from one wallet to another. What would you like to sweep?',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        CheckboxListTile(
          title: Text('RVN'),
          value: sweepCurrency,
          onChanged: (newValue) => sweepCurrency = newValue,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: Text('Assets'),
          value: sweepAssets,
          onChanged: (newValue) => sweepAssets = newValue,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
