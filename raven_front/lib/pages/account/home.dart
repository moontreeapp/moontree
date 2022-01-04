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
      child: NotificationListener<UserScrollNotification>(
          onNotification: visibilityOfSendReceive, child: HoldingList()),
      //floatingActionButtonLocation:
      //    FloatingActionButtonLocation.centerFloat,
      //floatingActionButton: isFabVisible ? sendReceiveButtons() : null,
      ////bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
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
            icon: Image(image: AssetImage('assets/icons/menu/menu.png')),
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
            Image(image: AssetImage('assets/icons/scan/scan.png')),
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

  Drawer accountsView() => Drawer(elevation: 0, child: NavDrawer());

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
