import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/services/account_creation.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<StreamSubscription> listeners =
      []; // most of these can move to header and body elements
  late String currentAccountId = '0'; // should be moved to body?
  final accountName = TextEditingController();
  bool isFabVisible = true;

  @override
  void initState() {
    super.initState();
    // gets cleaned up?
    currentTheme.addListener(() {
      // if user changes OS dark/light mode setting, refresh
      setState(() {});
    });
    listeners.add(balances.batchedChanges.listen((batchedChanges) {
      if (batchedChanges.isNotEmpty) setState(() {});
    }));
    listeners.add(settings.batchedChanges.listen((batchedChanges) {
      // todo: set the current account on the widget
      var changes = batchedChanges
          .where((change) => change.data.name == SettingName.Account_Current);
      if (changes.isNotEmpty)
        setState(() {
          currentAccountId = changes.first.data.value;
        });
    }));
  }

  @override
  void dispose() {
    //This method must not be called after dispose has been called. ??
    //currentTheme.removeListener(() {});
    for (var listener in listeners) {
      listener.cancel();
    }
    accountName.dispose();
    super.dispose();
  }

  void refresh([Function? f]) {
    services.rate.saveRate();
    services.balance.recalculateAllBalances();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: balanceHeader(),
      drawer: accountsView(),
      body: NotificationListener<UserScrollNotification>(
        onNotification: visibilityOfSendReceive,
        child: HoldingList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isFabVisible ? sendReceiveButtons() : null,
      //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
    );
  }

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward) {
      if (!isFabVisible) setState(() => isFabVisible = true);
    } else if (notification.direction == ScrollDirection.reverse) {
      if (isFabVisible) setState(() => isFabVisible = false);
    }
    return true;
  }

  PreferredSize balanceHeader() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
        automaticallyImplyLeading: true,
        actions: <Widget>[
          components.status,
          indicators.process,
          indicators.client,
        ],
        elevation: 2,
        centerTitle: false,
        title: SizedBox(
          height: 32,
          child: Image.asset('assets/rvn256.png'),
        ),
        flexibleSpace: Container(
            alignment: Alignment.center,
            // balance view should listen for valid usd
            // show spinnter until valid usd rate appears, then rvnUSD
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(accounts.data.length > 1 ? Current.account.name : 'Wallet',
                    style: Theme.of(context).textTheme.headline3),
                Text(
                    // this kinda thing should be abstracted:
                    '\n${Current.balanceUSD != null ? '' : ''} ${Current.balanceUSD?.valueUSD ?? Current.balanceRVN.valueRVN}',
                    style: Theme.of(context).textTheme.headline2),
              ],
            )),
      ));

  Drawer accountsView() => Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: <Widget>[
            DrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(Current.account.name,
                              style: Theme.of(context).textTheme.headline5),
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down_sharp,
                                size: 26.0, color: Colors.grey.shade200),
                            onPressed: () {
                              showModalBottomSheet<void>(
                                  context: context,
                                  enableDrag: true,
                                  builder: (BuildContext context) =>
                                      ListView(children: <Widget>[
                                        ...[
                                          ...createNewAcount(
                                            context,
                                            accountName,
                                          ),
                                          Divider(
                                              height: 20,
                                              thickness: 2,
                                              indent: 5,
                                              endIndent: 5)
                                        ],
                                        for (var account in accounts.data.where(
                                            (account) =>
                                                account.net ==
                                                settings.primaryIndex
                                                    .getOne(SettingName
                                                        .Electrum_Net)!
                                                    .value)) ...[
                                          ListTile(
                                              onTap: () async {
                                                await settings
                                                    .setCurrentAccountId(
                                                        account.accountId);
                                                accountName.text = '';
                                                Navigator.popUntil(
                                                    context,
                                                    ModalRoute.withName(
                                                        '/home'));
                                              },
                                              title: Text(
                                                  //account.accountId +
                                                  //    ' ' +
                                                  account.name,
                                                  style: account.accountId ==
                                                          currentAccountId
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .bodyText1
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .bodyText2),
                                              leading: components.icons
                                                  .assetAvatar('RVN')),
                                          Divider(
                                              height: 20,
                                              thickness: 2,
                                              indent: 5,
                                              endIndent: 5)
                                        ],
                                        ...[
                                          TextButton.icon(
                                              onPressed: () =>
                                                  Navigator.pushNamed(context,
                                                      '/settings/import'),
                                              icon: components.icons.import,
                                              label: Text('Import')),
                                        ],
                                      ])

                                  //{
                                  //  return Container(
                                  //    height: 200,
                                  //    color: Colors.amber,
                                  //    child: Center(
                                  //      child: Column(
                                  //        mainAxisAlignment: MainAxisAlignment.center,
                                  //        mainAxisSize: MainAxisSize.min,
                                  //        children: <Widget>[
                                  //          const Text('Modal BottomSheet'),
                                  //          ElevatedButton(
                                  //            child: const Text('Close BottomSheet'),
                                  //            onPressed: () => Navigator.pop(context),
                                  //          )
                                  //        ],
                                  //      ),
                                  //    ),
                                  //  );
                                  //},
                                  );
                            },
                          ),
                        ]),
                    //Row(
                    //  mainAxisAlignment: MainAxisAlignment.center,
                    //  children: [
                    //    Text(Current.account.name,
                    //        style: Theme.of(context).textTheme.headline2),
                    //  ],
                    //),
                  ],
                )),
            SettingsSection(
              titlePadding: EdgeInsets.only(left: 10, top: 10),
              title: 'Settings',
              tiles: [
                SettingsTile(
                    title: 'Preferences', // name, show conf screen, etc.
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.settings),
                    onPressed: (BuildContext context) =>
                        Navigator.pushNamed(context, '/settings/preferences')),
                SettingsTile(
                    title: 'Import',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: components.icons.import,
                    onPressed: (BuildContext context) =>
                        Navigator.pushNamed(context, '/settings/import')),
                SettingsTile(
                    title: 'Export',
                    subtitle: '(Backup)',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: components.icons.export,
                    onPressed: (BuildContext context) => Navigator.pushNamed(
                        context, '/settings/export',
                        arguments: {'accountId': 'current'})),
                /*
            SettingsTile(
                title: 'Sign Message',
                titleTextStyle: Theme.of(context).textTheme.bodyText2,
                enabled: false,
                leading: Icon(Icons.fact_check_sharp),
                onPressed: (BuildContext context) {
                  //Navigator.push(
                  //  context,
                  //  MaterialPageRoute(builder: (context) => ...()),
                  //);
                }),
            */
                SettingsTile(
                    title: 'Accounts',
                    subtitle: '(Detail)',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.lightbulb),
                    onPressed: (BuildContext context) =>
                        Navigator.pushNamed(context, '/settings/technical')),
                /* Coming soon!
            SettingsTile(
                title: 'P2P Exchange',
                titleTextStyle: Theme.of(context).textTheme.bodyText2,
                enabled: false,
                leading: Icon(Icons.swap_horiz),
                onPressed: (BuildContext context) {})
            */

                SettingsTile(
                    title: 'Password',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.password),
                    onPressed: (BuildContext context) =>
                        Navigator.pushNamed(context, '/password/change')),
                SettingsTile(
                    title: 'Network',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.network_check),
                    onPressed: (BuildContext context) =>
                        Navigator.pushNamed(context, '/settings/network')),
                /*
              SettingsTile(
                  title: 'Currency',
                  titleTextStyle: Theme.of(context).textTheme.bodyText2,
                  leading: Icon(Icons.money),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/currency')),
              SettingsTile(
                  title: 'Language',
                  titleTextStyle: Theme.of(context).textTheme.bodyText2,
                  subtitle: 'English',
                  leading: Icon(Icons.language),
                  onPressed: (BuildContext context) =>
                      Navigator.pushNamed(context, '/settings/language')),
              */
                SettingsTile(
                    title: 'About',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.info_outline_rounded),
                    onPressed: (BuildContext context) =>
                        Navigator.pushNamed(context, '/settings/about')),
/*                      
*/
                SettingsTile(
                    title: 'Clear Database',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.info_outline_rounded),
                    onPressed: (BuildContext context) {
                      ravenDatabase.deleteDatabase();
                    }),
                SettingsTile(
                    title: 'show data',
                    titleTextStyle: Theme.of(context).textTheme.bodyText2,
                    leading: Icon(Icons.info_outline_rounded),
                    onPressed: (BuildContext context) async {
                      print(balances.bySecurity.getAll(Security(
                          symbol: 'RVN', securityType: SecurityType.Crypto)));
                      print(balances.bySecurity.getAll(Security(
                          symbol: 'MOONTREE0',
                          securityType: SecurityType.RavenAsset)));
                      print(vouts.bySecurity.getAll(Security(
                          symbol: 'MOONTREE0',
                          securityType: SecurityType.RavenAsset)));
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
                //SettingsTile.switchTile(
                //  title: 'Use fingerprint',
                //  titleTextStyle: Theme.of(context).textTheme.bodyText2,
                //  leading: Icon(Icons.fingerprint),
                //  switchValue: true,
                //  onToggle: (bool value) {},
                //),
              ],
            ),
          ],
        ),
      );

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        components.buttons.receive(context),
        Current.holdings.length > 0
            ? components.buttons.send(context, symbol: 'RVN')
            : components.buttons.send(context, symbol: 'RVN', disabled: true),
      ]);
}
