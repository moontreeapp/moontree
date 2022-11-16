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
            padding: EdgeInsets.only(top: 16),
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
                icon: Padding(
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

isSelected(Chain chain, Net net) =>
    pros.settings.chain == chain && pros.settings.net == net;

isConnected() => streams.client.connected.value == ConnectionStatus.connected;

void produceBlockchainModal(
  BuildContext context, {
  Function(Tuple2<Chain, Net>)? first,
  Function? second,
}) =>
    SimpleSelectionItems(context, items: [
      ListTile(
          dense: true,
          leading: icons.evrmore(height: 24, width: 24, circled: true),
          title: Text('Evrmore',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: AppColors.black87)),
          trailing: isSelected(Chain.evrmore, Net.main) && isConnected()
              ? Icon(Icons.check_rounded, color: AppColors.primary)
              : null,
          onTap: () => !(isSelected(Chain.evrmore, Net.main) && isConnected())
              ? changeChainNet(
                  context,
                  Tuple2(Chain.evrmore, Net.main),
                  first: first,
                  second: second,
                )
              : null),
      ListTile(
          dense: true,
          leading: icons.ravencoin(height: 24, width: 24, circled: true),
          title: Text('Ravencoin',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: AppColors.black87)),
          trailing: isSelected(Chain.ravencoin, Net.main) && isConnected()
              ? Icon(Icons.check_rounded, color: AppColors.primary)
              : null,
          onTap: () => !(isSelected(Chain.ravencoin, Net.main) && isConnected())
              ? changeChainNet(
                  context,
                  Tuple2(Chain.ravencoin, Net.main),
                  first: first,
                  second: second,
                )
              : null),
      if (services.developer.advancedDeveloperMode)
        ListTile(
            leading: icons.evrmoreTest(height: 24, width: 24, circled: true),
            title: Text('Evrmore testnet',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: AppColors.black87)),
            trailing: isSelected(Chain.evrmore, Net.test) && isConnected()
                ? Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () => !(isSelected(Chain.evrmore, Net.test) && isConnected())
                ? changeChainNet(
                    context,
                    Tuple2(Chain.evrmore, Net.test),
                    first: first,
                    second: second,
                  )
                : null),
      if (services.developer.developerMode)
        ListTile(
            leading: icons.ravencoinTest(height: 24, width: 24, circled: true),
            title: Text('Ravencoin testnet',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: AppColors.black87)),
            trailing: isSelected(Chain.ravencoin, Net.test) && isConnected()
                ? Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () =>
                !(isSelected(Chain.ravencoin, Net.test) && isConnected())
                    ? changeChainNet(
                        context,
                        Tuple2(Chain.ravencoin, Net.test),
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
  streams.client.busy.add(true);
  (first ?? (_) {})(value);
  components.loading.screen(
    message:
        'Connecting to ${value.item1.name.toTitleCase()}${value.item2 == Net.test ? ' ' + value.item2.name.toTitleCase() : ''}',
    returnHome: false,
    playCount: 5,
  );
  await services.client.switchNetworks(chain: value.item1, net: value.item2);
  streams.app.snack.add(Snack(message: 'Successfully connected'));
  (second ?? () {})();
}
