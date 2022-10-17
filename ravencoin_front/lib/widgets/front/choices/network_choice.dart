import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/widgets/bottom/selection_items.dart';
import 'package:ravencoin_front/widgets/other/textfield.dart';
import 'package:ravencoin_front/widgets/assets/icons.dart';
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
  final choiceFocus = FocusNode();
  final choiceController = TextEditingController();
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
        TextFieldFormatted(
          focusNode: choiceFocus,
          controller: choiceController,
          readOnly: true,
          textInputAction: TextInputAction.next,
          decoration: components.styles.decorations.textField(context,
              focusNode: choiceFocus,
              labelText: 'Blockchain',
              hintText: 'Ravencoin',
              suffixIcon: IconButton(
                icon: Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.expand_more_rounded,
                        color: Color(0xDE000000))),
                onPressed: () => _produceAssetModal(),
              )),
          onTap: () {
            _produceAssetModal();
            setState(() {});
          },
          onEditingComplete: () async {
            FocusScope.of(context).requestFocus(choiceFocus);
          },
        ),

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
        if (pros.settings.advancedDeveloperMode)
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
        if (pros.settings.advancedDeveloperMode)
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

  void _produceAssetModal() => SimpleSelectionItems(context, items: [
        ListTile(
          leading: icons.evrmore(height: 24, width: 24, circled: true),
          title: Text('Evrmore'),
          trailing: null,
        ),
        //if (pros.settings.advancedDeveloperMode)
        //  ListTile(
        //    leading: svgIcons.evrmoreTest,
        //    title: Text('Evrmore (testnet)'),
        //    trailing: null,
        //  ),
        ListTile(
          leading: icons.ravencoin(height: 24, width: 24, circled: true),
          title: Text('Ravencoin'),
          trailing: null,
        ),
        //if (pros.settings.advancedDeveloperMode)
        //  ListTile(
        //    leading: svgIcons.ravencoinTest,
        //    title: Text('Ravencoin (testnet)'),
        //    trailing: null,
        //  ),
      ]).build();
}
