import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

//testing
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_electrum/methods/transaction/get.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer({Key? key}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  List listeners = [];
  String? chosen = '/settings';

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
  }) =>
      ListTile(
        onTap: () {
          if (!arrow) {
            Backdrop.of(components.navigator.routeContext!).fling();
            Navigator.of(components.navigator.routeContext!).pushNamed(link);
            streams.app.setting.add(null);
          } else {
            streams.app.setting.add(link);
          }
        },
        leading: icon != null ? Icon(icon, color: Colors.white) : image!,
        title: Text(name, style: Theme.of(context).drawerDestination),
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
              icon: MdiIcons.fileImport,
              name: 'Import',
              link: '/settings/import'),
          destination(
              icon: MdiIcons.fileExport,
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
              link: '/settings/network'),
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
            icon: Icons.settings,
            name: 'Settings',
            link: '/settings/settings',
            arrow: true,
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

/*
          SettingsTile(
              title: 'Clear Database',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) {
                ravenDatabase.deleteDatabase();
              }),
          destination(
            icon: MdiIcons.shieldKey,
            name: 'Accounts',
            link: '/settings/technical',
          ),
          SettingsTile(
              title: 'show data',
              titleTextStyle: Theme.of(context).drawerDestination,
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) async {
                var txs = res.vins.danglingVins
                    .map((vin) => vin.voutTransactionId)
                    .toSet();
                for (var tx in txs) {
                  print(tx);
                }
                print(await services.history.produceAddressOrBalance());
              }),
*/
          //var txHash =
          //    //'9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7';
          //    '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8';
          //var client = streams.client.client.value!;
          //var tx = await client.getTransaction(txHash);
          //print('---tx');
          //print(tx.txid);
          //print(tx);
          //print('---vin len');
          //print(tx.vin.length);
          //print('---vin 0');
          //print(tx.vin[0].txid);
          //print(tx.vin[0].vout);
          //print('---vin 1');
          //print(tx.vin[1].txid);
          //print(tx.vin[1].vout);
          //services.history.saveTransactions([tx], client);
          //for (var item in [
          //  '681c62266f6dc3c1c16ba5024c5bb875c627ab89815fd61f689519e06036832b',
          //  'f585233ccb19f93912c094e66d5681b73a4adcf3db50c7455e5d9b2a724b2345',
          //  '47f0fc510a930c56797d5bf2ed574e9a7d67153d8e34e6b342af6947d0efdddf',
          //  'e80568e961b4a978dcf5ab533638505823bbb83bbea2c742afb35f6b22ff96b6',
          //  'c512010a793a7a4296e1a34e1c11b94441226f602cf57c9b56d3a20307f02b41',
          //  'fe08c278ad54f3fdcc35aa6d05de7b955f22d842d9ef75a501fa82aa68dbc178',
          //  '00111be079656f15bc63afa843860f37e0ecbc6e374c2e35c11fac6eff9cb810',
          //  '5fd5dc8fbb486404feb24762a838c09131d225b3547b9fa318920d1593591139',
          //  'ef1be6f06025e6bd8d7e8319003296e168068ce9d08e6efc1612c06fcb13c330',
          //  '14de222d2825ec8e187e4d8c2785bdf26663d6d8e9f5475cb97a5e6376a64d56',
          //  '24031e0a46ae015cdb58d53dfb8910207d53b6a061387ffd2368730533043f3e',
          //  '6b5d00227fc75b590d693877a32ecce55664fd851238de1cfa3fae5ce1362862',
          //  '17b798480e340ae639c23a036ee39d61784b4418ca3d40c43ae2e7c9728e76e2',
          //  '6ef14bbacb9dc343eb9cde1f2a311ae787231613fc6ae863cec11752a56c3308',
          //  '53572c6054e8c00b847ed19682e487b1a44b4a28c3a6001bd84473db1c671044',
          //  '5cdde1dc17f820320011ec648272237322e1cde48e62158b3cb56999c5aba0e8',
          //  '7217229e9fa0e668aebc4d1478ab69320ee7d9b6ca6357c30a38b4b4a89a0c0d',
          //  'c88fe87a5df1f8fac0ba929a7021038d66947fd4aabef2368eb7aa21aea2c3c5',
          //  '9b64eb258a4352a68c4ce98cbbadddcbbcb285c422f7f9f97ed4b826d0a387d7',
          //]) {
          //  var tx = res.transactions.primaryIndex.getOne(item);
          //  print(tx);
          //}

          //var add = res.addresses.byAddress
          //    .getOne('ms9vMzmK3KB9j6gsLSXaLKKzfF17umue3D')!;
          //print(add);
          //print(add.address);
          //print(add.walletId);
          //print(add.hdIndex);
          //print(add.exposure);
          //print(add.vouts);

          //print(res.vouts.byAddress
          //    .getAll('ms9vMzmK3KB9j6gsLSXaLKKzfF17umue3D'));
          //print(res.vins.byVoutId.getOne(
          //    '86f9493e07cb039a3735ca7ac074a869464488d961ad60844134820fa67d6a56:0'));
          //print(res.vouts.primaryIndex
          //    .getOne(
          //        '90bf9bb181cb83dd9804a0a03186e6ae81a66ea738f3afd6b472387feb16d155:0')!
          //    .vin);
          //var tx = res.vouts.data
          //    //VoutReservoir.whereUnspent(includeMempool: false)
          //    .where((Vout vout) =>
          //        vout.account?.net ==
          //            res.settings.primaryIndex
          //                .getOne(SettingName.Electrum_Net)!
          //                .value &&
          //        (vout.transaction?.confirmed ?? false))
          //    .map((e) => e.assetSecurityId)
          //    .toList();
          //for (var id in tx) {
          //  print(id);
          //}
          //var tx = res.transactions.data;
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
      )
    };
    return Container(
        height: MediaQuery.of(context).size.height - 118 - 10,

        /// using a listview makes it variable so you don't have to define height
        //height: 300,
        //child: Column(
        //  crossAxisAlignment: CrossAxisAlignment.start,
        ///

        child: options[chosen] ?? options['/settings']);
  }
}
