import 'package:tuple/tuple.dart';
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
  Chain chainChoice = Chain.ravencoin;
  Net netChoice = Net.main;
  late Tuple2<Chain, Net> chainNet;

  @override
  void initState() {
    super.initState();
    chainChoice = pros.settings.chain;
    netChoice = pros.settings.net;
    chainNet = Tuple2(chainChoice, netChoice);
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
        //Text('Blockchain Network',
        //    style: Theme.of(context).textTheme.bodyText1),
        //Text(
        //  'Wallets can hold value on multiple blockchains. Which blockchain would you like to connect to?',
        //  style: Theme.of(context).textTheme.bodyText2,
        //),
        //await SimpleSelectionItems(
        //    components.navigator.routeContext!,
        //    then: () => dropDownActive = false,
        //    items: []),
        SizedBox(height: 16),
        RadioListTile<Tuple2<Chain, Net>>(
            title: const Text('Ravencoin'),
            value: Tuple2(Chain.ravencoin, Net.main),
            groupValue: chainNet,
            onChanged: changeChainNet),
        if (pros.settings.developerMode)
          RadioListTile<Tuple2<Chain, Net>>(
              title: const Text('Ravencoin (testnet)'),
              value: Tuple2(Chain.ravencoin, Net.test),
              groupValue: chainNet,
              onChanged: changeChainNet),
        RadioListTile<Tuple2<Chain, Net>>(
            title: const Text('Evrmore'),
            value: Tuple2(Chain.evrmore, Net.main),
            groupValue: chainNet,
            onChanged: changeChainNet),
        if (pros.settings.developerMode)
          RadioListTile<Tuple2<Chain, Net>>(
              title: const Text('Evrmore (testnet)'),
              value: Tuple2(Chain.evrmore, Net.test),
              groupValue: chainNet,
              onChanged: changeChainNet)
      ],
    );
  }

  void changeChainNet(Tuple2<Chain, Net>? value) async {
    streams.client.busy.add(true);
    setState(() {
      chainChoice = value!.item1;
      netChoice = value.item2;
      chainNet = value;
    });
    services.client.switchNetworks(value!.item1, net: value.item2);
    components.loading.screen(
      message:
          'Syncing with ${value.item1.name.toTitleCase()}${value.item2 == Net.test ? ' ' + value.item2.name.toTitleCase() : ''}',
      returnHome: true,
      playCount: 5,
    );
  }
}
