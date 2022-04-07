import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/streams/wallet.dart';

import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/zips.dart';

//import 'package:raven_back/utilities/database.dart' as ravenDatabase;

class NavMenu extends StatefulWidget {
  NavMenu({Key? key}) : super(key: key);

  @override
  _NavMenuState createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  List listeners = [];
  String? chosen = '/settings';

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.setting.listen((String? value) {
      if (value != chosen) {
        setState(() {
          chosen = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Widget destination({
    required String name,
    required String link,
    IconData? icon,
    Image? image,
    bool arrow = false,
    Map<String, dynamic>? arguments,
    Function? execute,
  }) =>
      ListTile(
        onTap: () {
          if (execute != null) {
            execute();
          }
          if (!arrow) {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(components.navigator.routeContext!).pushNamed(
              link,
              arguments: arguments,
            );
            streams.app.setting.add(null);
            streams.app.fling.add(false);
          } else {
            streams.app.setting.add(link);
          }
        },
        leading: icon != null ? Icon(icon, color: Colors.white) : image!,
        title: Text(name,
            style: Theme.of(context)
                .textTheme
                .bodyText1!
                .copyWith(color: AppColors.white)),
        trailing: arrow ? Icon(Icons.chevron_right, color: Colors.white) : null,
      );

  @override
  Widget build(BuildContext context) {
    var options = {
      '/settings/import_export': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: [
          destination(
              icon: MdiIcons.keyPlus, name: 'Import', link: '/settings/import'),
          destination(
              icon: MdiIcons.keyMinus,
              name: 'Export',
              link: '/settings/export'),
        ],
      ),
      '/settings/settings': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: [
          destination(
              icon: Icons.lock_rounded,
              name: 'Security',
              link: '/settings/security'),
          destination(
              icon: MdiIcons.accountCog,
              name: 'User Level',
              link: '/settings/level'),
          destination(
              icon: MdiIcons.network,
              name: 'Network',
              link: '/settings/network',
              execute: () {
                streams.app.verify.add(false);
              }),
        ],
      ),
      '/settings': ListView(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        children: [
          destination(
            icon: MdiIcons.shieldKey,
            name: 'Import / Export',
            link: '/settings/import_export',
            arrow: true,
          ),
          destination(
              icon: MdiIcons.drawPen,
              name: 'Backup',
              link: '/security/backup',
              execute: () {
                streams.app.verify.add(false);
              }),
          destination(
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
            arrow: true,
          ),
          destination(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/settings/feedback',
          ),
          destination(
            icon: Icons.help,
            name: 'Support',
            link: '/settings/support',
          ),
          destination(
            icon: Icons.info_rounded,
            name: 'About',
            link: '/settings/about',
          ),
          destination(
            icon: Icons.info_rounded,
            name: 'Wallet',
            link: '/wallet',
          ),
          /*
          SettingsTile(
              title: 'Clear Database',
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) {
            //    ravenDatabase.deleteDatabase();
          ),
          */
          ListTile(
              title: Text('test'),
              leading: Icon(Icons.info_outline_rounded),
              onTap: () async {
                //print(res.balances.bySecurity.getAll(res.securities.RVN));
                //print(res.vouts.bySecurity.getAll(res.securities.RVN).length);
                //for (var add in res.addresses.byWallet
                //    .getAll(res.wallets.currentWallet.id)) {
                //  var unspents =
                //      await services.client.client!.getUnspent(add.scripthash);
                //  for (var u in unspents) {
                //    print(u);
                //  }
                //}
                //for (var u in services.transaction
                //    .getTransactionRecords(wallet: Current.wallet)) {
                //  print(u);
                //}
                //print(services.balance.recalculateSpecificBalances(res
                //    .vouts.data
                //    //VoutReservoir.whereUnspent(includeMempool: false)
                //    .where((Vout vout) => vout.security == res.securities.RVN && (vout.transaction?.confirmed ?? false));
                //    .toList()));

                //await services.history
                //    .saveDanglingTransactions(services.client.client!);
                //await services.balance.recalculateAllBalances();

                //print('txsbywalletexposure: ${[
                //  for (var t in waiters.history.txsByWalletExposureKeys.keys)
                //    waiters.history.txsByWalletExposureKeys[t]?.length
                //]}');
                //print('txsbywalletexposure: ${[
                //  for (var t in waiters.history.txsByWalletExposureKeys.keys) t
                //]}');
                //print(waiters.history.txsByWalletExposureKeys[
                //    '03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342Internal']);
                ////waiters.history.manualPull(
                ////    keyedTransactionsKey:
                ////        '03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342Internal',
                ////    walletId:
                //////        '03d992f22d9e178a4de02e99ffffe885bd5135e65d183200da3b566502eca79342',
                //////    exposure: NodeExposure.Internal);
                //print(
                //    Current.wallet.getHighestSavedIndex(NodeExposure.Internal));
                //print(
                //    Current.wallet.getHighestSavedIndex(NodeExposure.External));
                //print(res.addresses.byWallet.getAll(Current.walletId).length);
                //print(
                //    Current.wallet.getHighestUsedIndex(NodeExposure.Internal));
                //print(
                //    Current.wallet.getHighestUsedIndex(NodeExposure.External));
                //print(services.wallet.leader.gapSatisfied(
                //    Current.wallet as LeaderWallet, NodeExposure.Internal));
                ////print(res.transactions.primaryIndex.getOne(
                ////    '7df22524d784b184fd5aaad900d638328c7cc3749f9f8b8c3ce648e80840494c'));
                ////for (var x in res.vouts.byTransaction.getAll(
                ////    '7df22524d784b184fd5aaad900d638328c7cc3749f9f8b8c3ce648e80840494c'))
                ////  print(x);
                //print([
                //  for (var t in waiters.history.txsByWalletExposureKeys.keys)
                //    waiters.history.txsByWalletExposureKeys[t]?.length
                //]);
                //print([
                //  for (var t
                //      in waiters.history.addressesByWalletExposureKeys.keys)
                //    waiters.history.addressesByWalletExposureKeys[t]?.length
                //]);
                //var addresses = res.addresses.byWallet.getAll(Current.walletId);
                //print(addresses.map((e) => e.exposure));
                //waiters.history.pullIf(WalletExposureTransactions(
                //    address: addresses[1], transactionIds: []));
                print('wallets');
                for (var w in res.wallets) {
                  print(w);
                }
                print('addresses');
                for (var w in res.addresses) {
                  print(w);
                }
                print('transactions');
                for (var w in res.transactions) {
                  print(w);
                }
                //print('vins');
                //for (var w in res.vins) {
                //  print(w);
                //}
                //print('vouts to me');
                //for (var w in res.vouts.where((e) => e.wallet != null)) {
                //  print(w);
                //}
                //print('vouts where vin');
                //for (var w in res.vouts.where((e) => e.vin != null)) {
                //  print(w);
                //}
                //for (var item in services.download.unspents
                //    .unspentsBySymbol[res.securities.RVN.symbol]!) {
                //  print(item);
                //}
                //print(services.download.unspents.total(res.securities.RVN));
                //print(services.download.unspents.unspentsBySymbol.keys);
                /*
                print(Current.wallet.highestSavedExternalIndex);
                print(Current.wallet.highestUsedExternalIndex);
                print(res.addresses.byWalletExposureIndex.getOne(
                    Current.walletId,
                    NodeExposure.External,
                    Current.wallet.highestSavedExternalIndex));
                print(res.addresses.byWalletExposureIndex.getOne(
                    Current.walletId,
                    NodeExposure.External,
                    Current.wallet.highestSavedExternalIndex + 1));
                print(res.addresses.byWalletExposureIndex.getOne(
                    Current.walletId,
                    NodeExposure.External,
                    Current.wallet.highestSavedExternalIndex + 2));
                for (var i in range(Current.wallet.highestSavedExternalIndex)) {
                  print(res.addresses.byWalletExposureIndex
                      .getOne(Current.walletId, NodeExposure.External, i));
                }
                for (var i in range(Current.wallet.highestSavedInternalIndex)) {
                  print(
                      '$i ${res.addresses.byWalletExposureIndex.getOne(Current.walletId, NodeExposure.Internal, i)}');
                }
                */
              }),
        ],
      )
    };
    return Container(
        height: MediaQuery.of(context).size.height - 118 - 10,
        color: Theme.of(context).backgroundColor,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                if (res.wallets.length > 1)
                  Divider(indent: 0, color: AppColors.white12),
                (options[chosen] ?? options['/settings'])!
              ]),
              services.password.required
                  ? Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Padding(
                          padding: EdgeInsets.only(left: 16, right: 16, top: 0),
                          child: Row(
                            children: [logoutButton],
                          )),
                      SizedBox(height: 40)
                    ])
                  : Container(),
            ]));
  }

  Widget get logoutButton => components.buttons.actionButton(
        context,
        label: 'Logout',
        invert: true,
        onPressed: logout,
      );

  void logout() async {
    res.ciphers.clear();
    Navigator.pushReplacementNamed(
        components.navigator.routeContext!, '/security/login',
        arguments: {});
    flingBackdrop(context);
  }
}
