import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/widgets/bottom/selection_items.dart';
import 'package:ravencoin_front/widgets/other/textfield.dart';
import 'package:ravencoin_front/widgets/assets/icons.dart';
import 'package:ravencoin_front/widgets/assets/filters.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/components/components.dart';

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
              //hintText: 'Ravencoin',
              helperText: services.client.connectionStatus &&
                      streams.client.connected.value ==
                          ConnectionStatus.connected
                  ? 'Connected'
                  : null,
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
                onPressed: () => _produceAssetModal(),
              ),
              onTap: () {
                _produceAssetModal();
                setState(() {});
              },
              onEditingComplete: () async {
                FocusScope.of(context).requestFocus(choiceFocus);
              },
            )),
      ],
    );
  }

  void _produceAssetModal() => SimpleSelectionItems(context, items: [
        ListTile(
            dense: true,
            leading: icons.evrmore(height: 24, width: 24, circled: true),
            title: Text('Evrmore',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: AppColors.black87)),
            trailing: chainChoice == Chain.evrmore && netChoice == Net.main
                ? Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () => changeChainNet(Tuple2(Chain.evrmore, Net.main))),
        if (pros.settings.developerMode)
          ListTile(
              leading: ColorFiltered(
                  colorFilter: filters.greyscale,
                  child: icons.evrmore(height: 24, width: 24, circled: true)),
              title: Text('Evrmore (testnet)',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: AppColors.black87)),
              trailing: chainChoice == Chain.evrmore && netChoice == Net.test
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => changeChainNet(Tuple2(Chain.evrmore, Net.test))),
        ListTile(
            dense: true,
            leading: icons.ravencoin(height: 24, width: 24, circled: true),
            title: Text('Ravencoin',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(color: AppColors.black87)),
            trailing: chainChoice == Chain.ravencoin && netChoice == Net.main
                ? Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
            onTap: () => changeChainNet(Tuple2(Chain.ravencoin, Net.main))),
        if (pros.settings.developerMode)
          ListTile(
              leading: ColorFiltered(
                  colorFilter: filters.greyscale,
                  child: icons.ravencoin(height: 24, width: 24, circled: true)),
              title: Text('Ravencoin (testnet)',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: AppColors.black87)),
              trailing: chainChoice == Chain.ravencoin && netChoice == Net.test
                  ? Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => changeChainNet(Tuple2(Chain.ravencoin, Net.test))),
      ]).build();

  void changeChainNet(Tuple2<Chain, Net> value) async {
    Navigator.of(context).pop();
    streams.client.busy.add(true);
    setState(() {
      chainChoice = value.item1;
      netChoice = value.item2;
      chainNet = value;
      showHelper = false;
    });
    await services.client.switchNetworks(value.item1, net: value.item2);
    await components.loading.screen(
      message:
          'Connecting to ${value.item1.name.toTitleCase()}${value.item2 == Net.test ? ' ' + value.item2.name.toTitleCase() : ''}',
      returnHome: false,
      playCount: 5,
    );
    streams.app.snack.add(Snack(message: 'Successfully connected'));
    setState(() {
      showHelper = true;
    });
  }
}
