import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/bottom/selection_items.dart';
import 'package:client_front/presentation/widgets/other/textfield.dart';
import 'package:client_front/presentation/widgets/assets/icons.dart';
import 'package:client_front/infrastructure/services/subscription.dart';

class BlockchainChoice extends StatefulWidget {
  const BlockchainChoice({Key? key, this.data}) : super(key: key);
  final dynamic data;

  @override
  _BlockchainChoice createState() => _BlockchainChoice();

  static const Set<String> disabledLocations = {
    '/',
    '/login/create',
    '/login/native',
    '/login/password',
    '/login/create/native',
    '/login/create/password',
    '/backup/intro',
    '/backup/seed',
    '/backup/verify',
    '/backup/keypair',
  };
}

class _BlockchainChoice extends State<BlockchainChoice> {
  final FocusNode choiceFocus = FocusNode();
  final TextEditingController choiceController = TextEditingController();
  Chain chainChoice = Chain.ravencoin;
  Net netChoice = Net.main;
  late ChainNet chainNet;
  bool showHelper = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void init() {
    chainChoice = pros.settings.chain;
    netChoice = pros.settings.net;
    chainNet = ChainNet(chainChoice, netChoice);
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
              helperStyle: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(height: .8, color: AppColors.primary),
              alwaysShowHelper: showHelper,
              textInputAction: TextInputAction.next,
              suffixIcon: IconButton(
                icon: const Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(Icons.expand_more_rounded,
                        color: Color(0xDE000000))),
                onPressed: () async {
                  navToBlockchain(context, refresh);
                },
              ),
              onTap: () async {
                navToBlockchain(context, refresh);
              },
              onEditingComplete: () async {
                FocusScope.of(context).requestFocus(choiceFocus);
              },
            )),
      ],
    );
  }

  void refresh() => setState(init);
}

bool isSelected(Chain chain, Net net) =>
    pros.settings.chain == chain && pros.settings.net == net;

bool isConnected() => components.cubits.connection.isConnected;

void produceBlockchainModal({
  BuildContext? context,
  Function(ChainNet)? first,
  Function? second,
}) =>
    SimpleSelectionItems(
      context ?? components.routes.routeContext!,
      items: blockchainOptions(),
    ).build();

List<Widget> blockchainOptions({
  BuildContext? context,
  Function? onTap,
  Function(ChainNet)? first,
  Function? second,
}) =>
    <Widget>[
      for (ChainBundle x in <ChainBundle>[
        ChainBundle(icons.evrmore, 'Evrmore', Chain.evrmore, Net.main),
        ChainBundle(icons.ravencoin, 'Ravencoin', Chain.ravencoin, Net.main),
        ChainBundle(
            icons.evrmoreTest, 'Evrmore testnet', Chain.evrmore, Net.test),
        ChainBundle(icons.ravencoinTest, 'Ravencoin testnet', Chain.ravencoin,
            Net.test),
      ])
        if (services
            .developer.featureLevelBlockchainMap[services.developer.userLevel]!
            .contains(x.chainNet))
          ListTile(
            onTap: () {
              if (onTap != null) {
                onTap();
              }
              //!(isSelected(x.chain, x.net) && isConnected())
              //? changeChainNet(
              //    context ?? components.routes.routeContext!,
              //    x.chainNet,
              //    first: first,
              //    second: second,
              //  )
              //: null;
              /// just do it even if it's already selected, to refresh conn
              changeChainNet(
                context ?? components.routes.routeContext!,
                x.chainNet,
                first: first,
                second: second,
              );
            },
            leading: x.icon(height: 24, width: 24, circled: true),
            title: Text(x.name,
                style: Theme.of(context ?? components.routes.context!)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.black87)),
            trailing: isSelected(x.chain, x.net) && isConnected()
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,
          ),
    ];

Future<void> changeChainNet(
  BuildContext context,
  ChainNet value, {
  Function(ChainNet)? first,
  Function? second,
}) async {
  //Navigator.of(context).pop();
  // streams.client.busy.add(true); // we want this here?
  (first ?? (_) {})(value);
  components.cubits.loadingView.show(
      title: 'Connecting',
      msg:
          '${value.chain.name.toTitleCase()}${value.net == Net.test ? ' ${value.net.name.toTitleCase()}' : ''}');
  //components.loading.screen(
  //  message:
  //      'Connecting to ${value.chain.name.toTitleCase()}${value.net == Net.test ? ' ${value.net.name.toTitleCase()}' : ''}',
  //  returnHome: false,
  //);
  components.cubits.connection.update(busy: true);
  // reset subscriptions to point to this chain
  await subscription.setupSubscription(
    wallet: pros.wallets.currentWallet,
    chain: value.chain,
    net: value.net,
  );
  await services.client.switchNetworks(chain: value.chain, net: value.net);
  components.cubits.connection.update(busy: false);
  await Future.delayed(Duration(milliseconds: 1330));
  streams.app.behavior.snack.add(Snack(message: 'Successfully connected'));
  await components.cubits.holdingsView.setHoldingViews(force: true);
  components.cubits.loadingView.hide();
  (second ?? () {})();
}

class ChainBundle {
  ChainBundle(this.icon, this.name, this.chain, this.net);
  final Widget Function({
    double? height,
    double? width,
    bool circled,
  }) icon;
  final String name;
  final Chain chain;
  final Net net;
  ChainNet get chainNet => ChainNet(chain, net);
}

void navToBlockchain([BuildContext? context, Function? then]) {
  //if (streams.app.behavior.scrim.value ?? false) {
  //  return;
  //}
  //if (streams.app.loading.value == true) {
  //  return;
  //}

  if (!BlockchainChoice.disabledLocations.contains(sail.latestLocation)) {
    ScaffoldMessenger.of(context ?? components.routes.context!)
        .clearSnackBars();
    //produceBlockchainModal(context: components.routes.routeContext!);
    components.cubits.bottomModalSheet.show(
      children: blockchainOptions(
        onTap: () {
          components.cubits.bottomModalSheet.hide();
          sail.home();
        },
        second: then ??
            () => sail.refreshHomeCubits(sail.locationFromSector(
                    components.cubits.location.state.sector) ??
                ''),
      ),
    );
    //Navigator.of(components.routes.routeContext!)
    //    .pushNamed('/settings/network/blockchain');
    // we'd really like to trigger this whenever we lose focus of it...
    components.cubits.title.update(editable: false);
  }
}
