import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';

class NetworkChoice extends StatefulWidget {
  final dynamic data;
  const NetworkChoice({this.data}) : super();

  @override
  _NetworkChoice createState() => _NetworkChoice();
}

class _NetworkChoice extends State<NetworkChoice> {
  Chain? networkChoice = Chain.ravencoin;

  @override
  void initState() {
    super.initState();
    networkChoice =
        pros.settings.netName == 'Main' ? Chain.ravencoin : Chain.evrmore;
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
        SizedBox(height: 16),
        RadioListTile<Chain>(
            title: const Text('Ravencoin (mainnet)'),
            value: Chain.ravencoin,
            groupValue: networkChoice,
            onChanged: (Chain? value) async {
              streams.client.busy.add(true);
              setState(() => networkChoice = value);
              services.client.switchNetworks(value, net: Net.Main);
              components.loading.screen(
                  message: 'Syncing with Ravencoin',
                  returnHome: true,
                  playCount: 5);
            }),
        RadioListTile<Chain>(
            title: const Text('Evrmore (mainnet)'),
            value: Chain.evrmore,
            groupValue: networkChoice,
            onChanged: (Chain? value) async {
              streams.client.busy.add(true);
              setState(() => networkChoice = value);
              services.client.switchNetworks(value, net: Net.Test);
              components.loading.screen(
                  message: 'Syncing with Evrmore',
                  returnHome: true,
                  playCount: 5);
            }),
      ],
    );
  }
}
