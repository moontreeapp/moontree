import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';

//import 'package:raven_front/services/lookup.dart';
//import 'package:raven_front/utils/zips.dart';
//import 'package:raven_front/theme/extensions.dart';
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
          /*
          destination(
              icon: MdiIcons.accountCog,
              name: 'User Level',
              link: '/settings/level'),
          */
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
            //execute: () {
            //  streams.app.verify.add(false);
            //}
          ),
          destination(
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
            arrow: true,
          ),
          /*
          destination(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/settings/feedback',
          ),
          */
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
          /*
          destination(
            icon: Icons.info_rounded,
            name: 'Wallet',
            link: '/wallet',
          ),
          destination(
              icon: Icons.info_outline_rounded,
              name: 'Clear Database',
              link: '/home',
              execute: ravenDatabase.deleteDatabase),
          ListTile(
              title: Text('test'),
              leading: Icon(Icons.info_outline_rounded),
              onTap: () async {
                //print(services.download.unspents.unspentsBySymbol);
                //print(services.download.unspents.total());
                //print(services.download.unspents.unspentsBySymbol['MOONTREE3']);
                //print(res.balances.data);
                //print(res.vouts.length);

                //var get = (e) => res.addresses.byWalletExposureIndex
                //    .getOne(Current.walletId, NodeExposure.External, e)!
                //    .address;
                ////var x = Current.wallet.emptyExternalAddresses
                ////    .map((e) => e.hdIndex)
                ////    .toList();
                ////x.sort();
                ////x.forEach((e) => print(get(e)));
                ////print('---');
                //(Current.wallet as LeaderWallet)
                //    .unusedExternalIndices
                //    .forEach((e) => print(get(e)));
                //// the old way is giving us an address that shouldn't exist (not empty)
                //// mnxzyHLczuYC8NaFNzs45xPku3fUo5SrdR
                //// why?
                //var a = res.addresses.byAddress
                //    .getOne('mkpbZecTxmzU78xqeaKAPeeDSfJw2sSAWt')!;
                //print(a.address);
                //print(a.id);
                //print(a.hdIndex);
                //print(a.exposure);
                //print(a);
                //print(res.vouts.byAddress
                //    .getAll('mkpbZecTxmzU78xqeaKAPeeDSfJw2sSAWt'));
                //res.transactions.chronological.forEach((element) => print(
                //    element.addresses
                //        ?.contains('mkpbZecTxmzU78xqeaKAPeeDSfJw2sSAWt')));
                //print(await services.client.client?.getHistory(a.id));
                //print(res.transactions.primaryIndex.getOne(
                //    '4e769a6d770b4e441ade1d5600926ad14f58fdb6ae4128ed03c811241ec72240'));
                //print(res.transactions.primaryIndex.getOne(
                //    'a172254a2aec36b73d00e03ef1c8005feec7fde54365edc232415081e91dd33d'));
                //print(services.download.history.downloadedOrDownloadQueried
                //    .contains(
                //        'a172254a2aec36b73d00e03ef1c8005feec7fde54365edc232415081e91dd33d'));
                //print(services.client.subscribe.subscriptionHandles.keys
                //    .contains('mit5fwMviprT5GJXsjMxismbCqvRpCtxPg'));
                //print(services.client.subscribe.subscriptionHandles.keys
                //    .contains(a.scripthash));
                //print('--');
                //print(await services.client.client!.getHistory(a.id));
                //print(await services.client.client!.getTransactions([
                //  'a172254a2aec36b73d00e03ef1c8005feec7fde54365edc232415081e91dd33d'
                //]));
                //print(services.wallet
                //    .getEmptyAddress(Current.wallet, random: true));
                //print(services.wallet
                //    .getEmptyAddress(Current.wallet, random: false));
                //print(services.wallet.getEmptyWallet(Current.wallet).address);
                //print(await services.client.client!.peer.done
                //    .asStream()
                //    .listen((event) {
                //  print('its done $event');
                //}));
                //print(services.client.client!.peer.isClosed);
                //try {
                //  print(await services.client.client!.getRelayFee());
                //} on StateError {
                //  print('err');
                //}
                print(Current.wallet);
                print(Current.wallet.addresses.length);
                print(Current.wallet.addresses);
              }),
          ListTile(
              title: Text('test'),
              leading: Icon(Icons.info_outline_rounded),
              onTap: () async {
                print(services.client.client);
                //print(await services.client.client!.peer.done);
                print(services.client.client!.peer.isClosed);
              }),
          */
          ListTile(
              title: Text('call'),
              leading: Icon(Icons.info_outline_rounded),
              onTap: () async {
                //print(services.client.client);
                //services.client.client!..close();
                //print(services.client.client);
                print(await services.client.scope(() async {
                  print('running');
                  return await services.client.client!.getRelayFee();
                }));
                //print('await services.client.client!.getRelayFee()');
                //print(await services.client.client!.getRelayFee());
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
    streams.app.splash.add(false);
  }
}
