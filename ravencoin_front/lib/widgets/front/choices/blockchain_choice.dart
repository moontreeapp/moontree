import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/bottom/selection_items.dart';
import 'package:ravencoin_front/widgets/other/textfield.dart';
import 'package:ravencoin_front/widgets/assets/icons.dart';

class BlockchainChoice extends StatefulWidget {
  final dynamic data;
  const BlockchainChoice({this.data}) : super();

  @override
  _BlockchainChoice createState() => _BlockchainChoice();
}

class _BlockchainChoice extends State<BlockchainChoice> {
  final choiceFocus = FocusNode();
  final choiceController = TextEditingController();
  Chain chainChoice = Chain.ravencoin;
  Net netChoice = Net.main;
  late Tuple2<Chain, Net> chainNet;
  bool showHelper = true;

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
    choiceController.text =
        '${chainChoice.name.toTitleCase()}${netChoice == Net.test ? ' (testnet)' : ''}';
    //FocusScope.of(context).requestFocus(choiceFocus);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.only(top: 16),
            child: TextFieldFormatted(
              focusNode: choiceFocus,
              controller: choiceController,
              readOnly: true,
              labelText: 'Blockchain',
              //helperText: services.client.connectionStatus &&
              //        streams.client.connected.value ==
              //            ConnectionStatus.connected
              //    ? 'Connected'
              //    : null,
              helperStyle: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(height: .8, color: AppColors.primary),
              alwaysShowHelper: showHelper,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: const Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.expand_more_rounded,
                        color: Color(0xDE000000))),
                onPressed: _produceBlockchainModal,
              ),
              onTap: _produceBlockchainModal,
              onEditingComplete: () async {
                FocusScope.of(context).requestFocus(choiceFocus);
              },
            )),
      ],
    );
  }

  void _produceBlockchainModal() => produceBlockchainModal(
        context,
        first: (Tuple2<Chain, Net> value) => setState(() {
          chainChoice = value.item1;
          netChoice = value.item2;
          chainNet = value;
          showHelper = false;
        }),
        second: () => setState(() => showHelper = true),
      );
}

bool isSelected(Chain chain, Net net) =>
    pros.settings.chain == chain && pros.settings.net == net;

bool isConnected() =>
    streams.client.connected.value == ConnectionStatus.connected;

void produceBlockchainModal(
  BuildContext context, {
  Function(Tuple2<Chain, Net>)? first,
  Function? second,
}) =>
    SimpleSelectionItems(context, items: [
      for (var x in [
        ChainBundle(icons.evrmore, 'Evrmore', Chain.evrmore, Net.main),
        ChainBundle(icons.ravencoin, 'Ravencoin', Chain.ravencoin, Net.main),
        ChainBundle(
            icons.evrmoreTest, 'Evrmore testnet', Chain.evrmore, Net.test),
        ChainBundle(icons.ravencoinTest, 'Ravencoin testnet', Chain.ravencoin,
            Net.test),
      ])
        if (services
            .developer.featureLevelBlockchainMap[services.developer.userLevel]!
            .contains(Tuple2(x.chain, x.net)))
          ListTile(
              leading: x.icon(height: 24, width: 24, circled: true),
              title: Text(x.name,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: AppColors.black87)),
              trailing: isSelected(x.chain, x.net) && isConnected()
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => !(isSelected(x.chain, x.net) && isConnected())
                  ? changeChainNet(
                      context,
                      Tuple2(x.chain, x.net),
                      first: first,
                      second: second,
                    )
                  : null),
    ]).build();

void changeChainNet(
  BuildContext context,
  Tuple2<Chain, Net> value, {
  Function(Tuple2<Chain, Net>)? first,
  Function? second,
}) async {
  Navigator.of(context).pop();
  (first ?? (_) {})(value);
  components.loading.screen(
    message:
        'Connecting to ${value.item1.name.toTitleCase()}${value.item2 == Net.test ? ' ' + value.item2.name.toTitleCase() : ''}',
    returnHome: false,
  );
  streams.client.busy.add(true);
  await services.client.switchNetworks(chain: value.item1, net: value.item2);
  streams.app.snack.add(Snack(message: 'Successfully connected'));
  (second ?? () {})();
}

class ChainBundle {
  final Widget Function({
    double? height,
    double? width,
    bool circled,
  }) icon;
  final String name;
  final Chain chain;
  final Net net;
  ChainBundle(this.icon, this.name, this.chain, this.net);
}
