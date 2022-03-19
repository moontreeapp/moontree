import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:raven_front/backdrop/backdrop.dart';
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

//testing
import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_electrum/methods/transaction/get.dart';

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
    //listeners.add(streams.app.page.listen((value) {
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
            Backdrop.of(components.navigator.routeContext!).fling();
            Navigator.of(components.navigator.routeContext!).pushNamed(
              link,
              arguments: arguments,
            );
            streams.app.setting.add(null);
          } else {
            streams.app.setting.add(link);
          }
        },
        leading: icon != null ? Icon(icon, color: Colors.white) : image!,
        title: Text(name, style: Theme.of(context).textTheme.headline5),
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
          /*
          SettingsTile(
              title: 'Clear Database',
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) {
                ravenDatabase.deleteDatabase();
              }),
          destination(
            icon: Icons.info_rounded,
            name: 'Accounts',
            link: '/settings/technical',
          ),
          SettingsTile(
              title: 'test',
              leading: Icon(Icons.info_outline_rounded),
              onPressed: (BuildContext context) async {
                print(res.transactions.data.where((element) =>
                    element.id ==
                    'e9ec208d98a621758af246f5c9253843cdbb744365eb234cc8eb201f002ca280'));
                print(res.vouts.data.where((element) =>
                    element.transactionId ==
                    'e9ec208d98a621758af246f5c9253843cdbb744365eb234cc8eb201f002ca280'));
                print(waiters.history.txsByWalletExposureKeys);
              }),
          */
        ],
      )
    };
    return Container(
        height: MediaQuery.of(context).size.height - 118 - 10,
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
