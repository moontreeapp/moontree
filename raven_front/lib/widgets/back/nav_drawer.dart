import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

/*
*/
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
                print(res.addresses.byAddress
                    .getOne('myA4k4Eogr2DXNibjmS2YSn2M2VT1d7tVD'));
                print(res.vouts.byAddress
                    .getAll('mxv3WJ9kfBxcwhrrEZ1EWa7xJHWXDKvnEU')[0]
                    .vin);
                print(res.vins.byVoutId.getOne(
                    '86f9493e07cb039a3735ca7ac074a869464488d961ad60844134820fa67d6a56:0'));
                print(res.vouts.primaryIndex
                    .getOne(
                        '90bf9bb181cb83dd9804a0a03186e6ae81a66ea738f3afd6b472387feb16d155:0')!
                    .vin);
                var tx = res.vouts.data
                    //VoutReservoir.whereUnspent(includeMempool: false)
                    .where((Vout vout) =>
                        vout.account?.net ==
                            res.settings.primaryIndex
                                .getOne(SettingName.Electrum_Net)!
                                .value &&
                        (vout.transaction?.confirmed ?? false))
                    .map((e) => e.assetSecurityId)
                    .toList();
                for (var id in tx) {
                  print(id);
                }
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
