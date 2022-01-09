import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

//import 'package:backdrop/backdrop.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

class NavDrawer extends StatefulWidget {
  NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  List listeners = [];

  @override
  void initState() {
    super.initState();
    //listeners.add(streams.app.page.stream.listen((value) {
    //  if (value != pageTitle) {
    //    setState(() {
    //      pageTitle = value;
    //    });
    //  }
    //}));
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
  }) =>
      TextButton.icon(
        onPressed: () {
          Backdrop.of(components.navigator.routeContext!).fling();
          Navigator.of(components.navigator.routeContext!).pushNamed(link);
        },
        icon: icon != null ? Icon(icon, color: Colors.white) : image!,
        label: Row(children: [
          SizedBox(width: 25),
          Text(name, style: Theme.of(context).drawerDestination)
        ]),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8),

      /// using a listview makes it variable so you don't have to define height
      //height: 300,
      //child: Column(
      //  crossAxisAlignment: CrossAxisAlignment.start,
      ///

      child: ListView(
        shrinkWrap: true,
        children: [
          destination(
            icon: MdiIcons.shieldKey,
            name: 'Import / Export',
            link: '/settings/import_export',
          ),
          destination(
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
          ),
          destination(
            icon: Icons.feedback,
            name: 'Feedback',
            link: '/settings/preferences',
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

          ////SettingsTile(
          ////    title: 'Import/Export',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.account_balance_wallet,
          ////        color: Colors.white), // plus?
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/import')),
          ////SettingsTile(
          ////    title: 'Settings',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.settings, color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/preferences')),
          ////SettingsTile(
          ////    title: 'Feedback',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.feedback, color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/preferences')),
          ////SettingsTile(
          ////    title: 'Support',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.help, color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/preferences')),
          ////SettingsTile(
          ////    title: 'About',
          ////    titleTextStyle: Theme.of(context).drawerDestination,
          ////    leading: Icon(Icons.info_outline_rounded,
          ////        color: Colors.white),
          ////    onPressed: (BuildContext context) =>
          ////        Navigator.pushNamed(context, '/settings/about')),

          ////// These belong in Settings
          //accounts.length > 1 ?
          //SettingsTile(
          //    title: 'Accounts',
          //    subtitle: '(Detail)',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.lightbulb),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/settings/technical'))
          //: Text('');
          //
          //SettingsTile(
          //    title: 'Preferences',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.settings),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/settings/preferences')),
          //SettingsTile(
          //    title: 'Password',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.password),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/security/change')),
          //SettingsTile(
          //    title: 'Network',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: Icon(Icons.network_check),
          //    onPressed: (BuildContext context) =>
          //        Navigator.pushNamed(context, '/settings/network')),

          //SettingsTile(
          //    title: 'Export',
          //    subtitle: '(Backup)',
          //    titleTextStyle: Theme.of(context).drawerDestination,
          //    leading: components.icons.export,
          //    onPressed: (BuildContext context) => Navigator.pushNamed(
          //        context, '/settings/export',
          //        arguments: {'accountId': 'current'})),
          /*
            SettingsTile(
                title: 'Sign Message',
                titleTextStyle: Theme.of(context).drawerDestination,
                enabled: false,
                leading: Icon(Icons.fact_check_sharp),
                onPressed: (BuildContext context) {
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ...()),
                  //);
                }),
            */

          /* Coming soon!
            SettingsTile(
                title: 'P2P Exchange',
                titleTextStyle: Theme.of(context).drawerDestination,
                enabled: false,
                leading: Icon(Icons.swap_horiz),
                onPressed: (BuildContext context) {})
            */

          /*
              SettingsTile(
                  title: 'Currency',
                  titleTextStyle: Theme.of(context).drawerDestination,
                  leading: Icon(Icons.money),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/currency')),
              SettingsTile(
                  title: 'Language',
                  titleTextStyle: Theme.of(context).drawerDestination,
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/language')),
              */
          SettingsTile(
              title: 'Clear Database',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) {
                ravenDatabase.deleteDatabase();
              }),
          SettingsTile(
              title: 'show data',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) async {
                print(balances.bySecurity.getAll(Security(
                    symbol: 'RVN', securityType: SecurityType.Crypto)));
                //print(transactions.mempool);
                //print(transactions.mempool.first.vouts);
                //print(transactions.mempool.first.vins);
                //for (var v in transactions.mempool.first.vouts) {
                //  print(v.transaction!.confirmed);
                //}
                //print(vouts.data.where((vout) => vout.position < 0));
                //print(VoutReservoir.whereUnconfirmed(
                //    security: securities.RVN));
                //print(VoutReservoir.whereUnspent(
                //        security: securities.RVN, includeMempool: false)
                //    .where((v) =>
                //        v.transactionId ==
                //        'b13feb18ae0b66f47e1606230b0a70de7d40ab52fbfc5626488136fbaa668b34'));
                for (var v in //vouts.data
                    VoutReservoir.whereUnspent(
                        security: securities.RVN, includeMempool: false)) {
                  //.where((Vout vout) =>
                  //    vout.account?.net ==
                  //        settings.primaryIndex
                  //            .getOne(SettingName.Electrum_Net)!
                  //            .value &&
                  //    (vout.transaction?.confirmed ?? false))) {
                  print(v);
                }
                print(VoutReservoir.whereUnspent(
                        security: securities.RVN, includeMempool: false)
                    .map((e) => e.rvnValue)
                    .toList()
                    .sumInt());
                //.where((v) =>
                //    v.transactionId ==
                //    'b13feb18ae0b66f47e1606230b0a70de7d40ab52fbfc5626488136fbaa668b34'));
                print('${Current.balanceUSD != null ? '' : ''}');
                print(Current.balanceUSD?.valueUSD);
                print(Current.balanceRVN.valueRVN);
                //print(vouts.data.where((vout) =>
                //    ((vout.transaction?.confirmed ?? false) &&
                //        vout.security == securities.RVN &&
                //        vout.securityValue(security: securities.RVN) >
                //            0 &&
                //        vins
                //            .where((vin) => (vin.voutTransactionId ==
                //                    vout.transactionId &&
                //                vin.voutPosition == vout.position))
                //            .toList()
                //            .isEmpty)));
                //print(VoutReservoir.whereUnspent(
                //        given: Current.account.vouts,
                //        security: securities.RVN)
                //    .toList());
                //print(VoutReservoir.whereUnspent(
                //        given: Current.account.vouts,
                //        security: securities.bySymbolSecurityType
                //            .getOne('MOONTREE', SecurityType.RavenAsset))
                //    .toList());
                //print(Current.account.vouts.first);
                //print(Current.account.vouts.first
                //    .securityValue(security: securities.RVN));
              }),
/*
*/
          //SettingsTile.switchTile(
          //  title: 'Use fingerprint',
          //  titleTextStyle: Theme.of(context).drawerDestination,
          //  leading: Icon(Icons.fingerprint),
          //  switchValue: true,
          //  onToggle: (bool value) {},
          //),
        ],
      ),
    );
  }
}
