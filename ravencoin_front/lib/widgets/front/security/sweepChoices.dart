import 'package:flutter/material.dart';

class SweepChoices extends StatefulWidget {
  const SweepChoices({Key? key, this.data}) : super(key: key);
  final dynamic data;

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Sweep', style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Sweeping means moving all value from one wallet to another. What would you like to sweep?',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          title: const Text('RVN'),
          value: sweepCurrency,
          onChanged: (bool? newValue) => sweepCurrency = newValue,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('Assets'),
          value: sweepAssets,
          onChanged: (bool? newValue) => sweepAssets = newValue,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
