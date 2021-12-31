import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/extensions/list.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/connection.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/services/account.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:raven_back/utils/database.dart' as ravenDatabase;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  List<StreamSubscription> listeners =
      []; // most of these can move to header and body elements
  late String currentAccountId = '0'; // should be moved to body?
  final accountName = TextEditingController();
  bool isFabVisible = true;
  final changeName = TextEditingController();

  @override
  void initState() {
    super.initState();

    // gets cleaned up?
    //currentTheme.addListener(() { // happens anyway.
    //  // if user changes OS dark/light mode setting, refresh
    //  setState(() {});
    //});
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
    changeName.text = accounts.data.length > 1
        ? 'Wallets / ' + Current.account.name
        : 'Wallet';
    print(MediaQuery.of(context).devicePixelRatio);
    print(MediaQuery.of(context).size);
    print(Navigator.of(context).toString());
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: _key,
          appBar: header(),
          drawer: Container(
              // container size is 304 by default. reguardless of device size
              // I don't think this is a problem we're supposed to solve for.
              //width: MediaQuery.of(context).size.width - 56, //336.7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0)),
                  color: const Color(0xffffffff),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x33000000),
                        offset: Offset(2, 0),
                        blurRadius: 4),
                    BoxShadow(
                        color: const Color(0x1F000000),
                        offset: Offset(1, 0),
                        blurRadius: 20),
                    BoxShadow(
                        color: const Color(0x24000000),
                        offset: Offset(4, 0),
                        blurRadius: 5),
                  ]),
              child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.0),
                      bottomRight: Radius.circular(8.0)),
                  child: accountsView())),
          body: NotificationListener<UserScrollNotification>(
              onNotification: visibilityOfSendReceive, child: HoldingList()),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: isFabVisible ? sendReceiveButtons() : null,
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  bool visibilityOfSendReceive(notification) {
    if (notification.direction == ScrollDirection.forward) {
      if (!isFabVisible) setState(() => isFabVisible = true);
    } else if (notification.direction == ScrollDirection.reverse) {
      if (isFabVisible) setState(() => isFabVisible = false);
    }
    return true;
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: SafeArea(
          child: Stack(children: [
        components.headers.shadows,
        AppBar(
          //primary: true,
          //automaticallyImplyLeading: true,
          //leading: ElevatedButton(
          //    onPressed: () => _key.currentState!.openDrawer(),
          //    child: SvgPicture.asset(
          //        'assets/icons/menu_24px.svg'), //Image(image: AssetImage('assets/icons/menu_24px.svg')),
          //    style: ButtonStyle(
          //      backgroundColor: MaterialStateProperty.all(Colors.white),
          //      foregroundColor: MaterialStateProperty.all(Colors.white),
          //      elevation: MaterialStateProperty.all(1),
          //      padding: MaterialStateProperty.all(EdgeInsets.zero),
          //      fixedSize: MaterialStateProperty.all(Size(36, 24)),
          //    )),
          leading: IconButton(
            onPressed: () => _key.currentState!.openDrawer(),
            padding: EdgeInsets.only(left: 16),
            icon: Image(image: AssetImage('assets/icons/menu_24px.png')),
            //icon: SvgPicture.asset(
            //  'assets/icons/menu_24px.svg',
            //  width: 36,
            //  height: 24,
            //  fit: BoxFit.fitWidth,
            //  allowDrawingOutsideViewBox: true,
            //), //Image(image: AssetImage('assets/icons/menu_24px.svg')),
          ),
          centerTitle: false,
          actions: <Widget>[
            components.status,
            ConnectionLight(),
            SizedBox(width: 16),
            Image(image: AssetImage('assets/icons/scan_24px.png')),
            SizedBox(width: 16)
          ],
          title: accounts.length > 1
              ? TextField(
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).pageTitle,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none),
                  controller: changeName,
                  onTap: () {
                    changeName.text = 'Wallets / ';
                    changeName.selection = TextSelection.fromPosition(
                        TextPosition(offset: changeName.text.length));
                  },
                  onSubmitted: (value) async {
                    if (!await updateAcount(Current.account,
                        value.replaceFirst('Wallets / ', ''))) {
                      components.alerts.failure(context,
                          headline: 'Unable rename account',
                          msg: 'Account name, "$value" is already taken. '
                              'Please enter a uinque account name.');
                    }
                    setState(() {});
                  },
                )
              : Text('Wallet', style: Theme.of(context).pageTitle),
        )
      ])));

  Drawer accountsView() => Drawer(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            PreferredSize(
              preferredSize: Size.fromHeight(144),
              child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child:

                      /// (future enhancement)
                      //accounts.length <= 1
                      //? // just show moontree logo and name, big in center
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              //SizedBox(width: 1),
                              Image(
                                  image: AssetImage('assets/logo/moontree.png'),
                                  height: 56,
                                  width: 47.84),
                              SizedBox(width: 8),
                              Text('Moontree',
                                  style: Theme.of(context).drawerTitle),
                            ])
                      ])
                  //:
                  //// show moontree logo and name smaller at the top,
                  //// account name center big
                  //Column(
                  //    mainAxisAlignment: MainAxisAlignment.start,
                  //    crossAxisAlignment: CrossAxisAlignment.start,
                  //    children: [
                  //      Column(
                  //        crossAxisAlignment: CrossAxisAlignment.start,
                  //        children: [
                  //          Row(
                  //              mainAxisAlignment:
                  //                  MainAxisAlignment.spaceBetween,
                  //              children: <Widget>[
                  //                SizedBox(width: 4),
                  //                Image(
                  //                    image: AssetImage(
                  //                        'assets/logo/moontree.png'),
                  //                    height: 56,
                  //                    width: 47.84),
                  //                SizedBox(width: 6),
                  //                Text('Moontree',
                  //                    style:
                  //                        Theme.of(context).drawerTitleSmall)
                  //              ]),
                  //          Row(
                  //            mainAxisAlignment:
                  //                MainAxisAlignment.spaceBetween,
                  //            children: [
                  //              Text(Current.account.name,
                  //                  style: Theme.of(context).drawerTitle),
                  //              IconButton(
                  //                icon: Icon(Icons.arrow_drop_down_sharp,
                  //                    size: 26.0,
                  //                    color: Colors.grey.shade200),
                  //                onPressed: () {
                  //                  showModalBottomSheet<void>(
                  //                    context: context,
                  //                    enableDrag: true,
                  //                    builder: (BuildContext context) =>
                  //                        ListView(
                  //                      children: <Widget>[
                  //                        ...[
                  //                          ...createNewAcount(
                  //                            context,
                  //                            accountName,
                  //                          ),
                  //                          Divider(
                  //                            height: 20,
                  //                            thickness: 2,
                  //                            indent: 5,
                  //                            endIndent: 5,
                  //                          ),
                  //                        ],
                  //                        for (var account in accounts.data
                  //                            .where((account) =>
                  //                                account.net ==
                  //                                settings.primaryIndex
                  //                                    .getOne(SettingName
                  //                                        .Electrum_Net)!
                  //                                    .value)) ...[
                  //                          ListTile(
                  //                            onTap: () async {
                  //                              await settings
                  //                                  .setCurrentAccountId(
                  //                                      account.accountId);
                  //                              accountName.text = '';
                  //                              Navigator.popUntil(
                  //                                context,
                  //                                ModalRoute.withName(
                  //                                    '/home'),
                  //                              );
                  //                            },
                  //                            title: Text(
                  //                              //account.accountId +
                  //                              //    ' ' +
                  //                              account.name,
                  //                              style: account.accountId ==
                  //                                      currentAccountId
                  //                                  ? Theme.of(context)
                  //                                      .textTheme
                  //                                      .bodyText1
                  //                                  : Theme.of(context)
                  //                                      .textTheme
                  //                                      .bodyText2,
                  //                            ),
                  //                            leading: components.icons
                  //                                .assetAvatar('RVN'),
                  //                          ),
                  //                          Divider(
                  //                            height: 20,
                  //                            thickness: 2,
                  //                            indent: 5,
                  //                            endIndent: 5,
                  //                          ),
                  //                        ],
                  //                        ...[
                  //                          TextButton.icon(
                  //                            onPressed: () =>
                  //                                Navigator.pushNamed(context,
                  //                                    '/settings/import'),
                  //                            icon: components.icons.import,
                  //                            label: Text('Import'),
                  //                          ),
                  //                        ],
                  //                      ],
                  //                    ),
                  //                  );
                  //                },
                  //              ),
                  //            ],
                  //          ),
                  //        ],
                  //      ),
                  //    ],
                  //  ),
                  ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/settings/import'),
                    icon: Icon(Icons.account_balance_wallet,
                        color: Color(0xFF666666)), // plus?
                    label: Row(children: [
                      SizedBox(width: 20),
                      Text('Import/Export',
                          style: Theme.of(context).drawerDestination)
                    ]),
                  ),
                  TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings/preferences'),
                      icon: Icon(Icons.settings, color: Color(0xFF666666)),
                      label: Row(children: [
                        SizedBox(width: 20),
                        Text('Settings',
                            style: Theme.of(context).drawerDestination)
                      ])),
                  TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings/preferences'),
                      icon: Icon(Icons.feedback, color: Color(0xFF666666)),
                      label: Row(children: [
                        SizedBox(width: 20),
                        Text('Feedback',
                            style: Theme.of(context).drawerDestination)
                      ])),
                  TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings/preferences'),
                      icon: Icon(Icons.help, color: Color(0xFF666666)),
                      label: Row(children: [
                        SizedBox(width: 20),
                        Text('Support',
                            style: Theme.of(context).drawerDestination)
                      ])),
                  TextButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings/about'),
                      icon: Icon(Icons.info_outline_rounded,
                          color: Color(0xFF666666)),
                      label: Row(children: [
                        SizedBox(width: 20),
                        Text('About',
                            style: Theme.of(context).drawerDestination)
                      ])),

                  ////SettingsTile(
                  ////    title: 'Import/Export',
                  ////    titleTextStyle: Theme.of(context).drawerDestination,
                  ////    leading: Icon(Icons.account_balance_wallet,
                  ////        color: Color(0xFF666666)), // plus?
                  ////    onPressed: (BuildContext context) =>
                  ////        Navigator.pushNamed(context, '/settings/import')),
                  ////SettingsTile(
                  ////    title: 'Settings',
                  ////    titleTextStyle: Theme.of(context).drawerDestination,
                  ////    leading: Icon(Icons.settings, color: Color(0xFF666666)),
                  ////    onPressed: (BuildContext context) =>
                  ////        Navigator.pushNamed(context, '/settings/preferences')),
                  ////SettingsTile(
                  ////    title: 'Feedback',
                  ////    titleTextStyle: Theme.of(context).drawerDestination,
                  ////    leading: Icon(Icons.feedback, color: Color(0xFF666666)),
                  ////    onPressed: (BuildContext context) =>
                  ////        Navigator.pushNamed(context, '/settings/preferences')),
                  ////SettingsTile(
                  ////    title: 'Support',
                  ////    titleTextStyle: Theme.of(context).drawerDestination,
                  ////    leading: Icon(Icons.help, color: Color(0xFF666666)),
                  ////    onPressed: (BuildContext context) =>
                  ////        Navigator.pushNamed(context, '/settings/preferences')),
                  ////SettingsTile(
                  ////    title: 'About',
                  ////    titleTextStyle: Theme.of(context).drawerDestination,
                  ////    leading: Icon(Icons.info_outline_rounded,
                  ////        color: Color(0xFF666666)),
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
                  //        Navigator.pushNamed(context, '/password/change')),
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
                                security: securities.RVN,
                                includeMempool: false)) {
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
            ),
          ],
        ),
      );

  Row sendReceiveButtons() =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        components.buttons.receive(context),

        /// while testnet is down comment this out.
        //Current.holdings.length > 0
        //    ? components.buttons.send(context, symbol: 'RVN')
        //    : components.buttons.send(context, symbol: 'RVN', disabled: true),

        components.buttons.send(context, symbol: 'RVN'),
      ]);
}
