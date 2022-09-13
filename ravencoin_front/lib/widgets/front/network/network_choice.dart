import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

enum NetworkChoices {
  ravencoin,
  evrmore,
}

class NetworkChoice extends StatefulWidget {
  final dynamic data;
  const NetworkChoice({this.data}) : super();

  @override
  _NetworkChoice createState() => _NetworkChoice();
}

class _NetworkChoice extends State<NetworkChoice> {
  NetworkChoices? networkChoice = NetworkChoices.ravencoin;

  @override
  void initState() {
    super.initState();
    networkChoice = pros.settings.netName == 'Main'
        ? NetworkChoices.ravencoin
        : NetworkChoices.evrmore;
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
        Text('Blockchain Network',
            style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Wallets can hold value on multiple blockchains. Which blockchain would you like to connect to?',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        RadioListTile<NetworkChoices>(
          title: const Text('Ravencoin (mainnet)'),
          value: NetworkChoices.ravencoin,
          groupValue: networkChoice,
          onChanged: (NetworkChoices? value) =>
              setState(() => networkChoice = value),
        ),
        RadioListTile<NetworkChoices>(
          title: const Text('Evrmore (mainnet)'),
          value: NetworkChoices.evrmore,
          groupValue: networkChoice,
          onChanged: (NetworkChoices? value) =>
              setState(() => networkChoice = value),
        ),
      ],
    );
  }
}
