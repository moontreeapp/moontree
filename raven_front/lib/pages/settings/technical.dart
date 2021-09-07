/// clicking the Accounts name should take you to the accounts technical view
/// where you can move, rename, reorder (must be saved in new reservoir or on
/// accounts objects), delete, move wallets and view details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/utils/utils.dart';

//import 'package:flutter_treeview/flutter_treeview.dart';
/// make our own 2-layer hierarchy view
/// use draggable to move things between the levels:
///
/// view Balances? should be easy balances are saved by wallet and by account...
///
/// header [ import -> import page, export all accounts -> file]
/// account [ renamable by click ] (drag target) [ set as default, delete ( must be empty of wallets ), import-> set that account as current and go to import page, export -> file ]
///   wallet [ rename? type and id... ] (draggable) [ view details?, export -> show private key or seed phrase ]
///
/// the wallet should just be clickable so you can do all the actions, except drag in there. import export delete

class TechnicalView extends StatefulWidget {
  final dynamic data;
  const TechnicalView({this.data}) : super();

  @override
  _TechnicalViewState createState() => _TechnicalViewState();
}

class _TechnicalViewState extends State<TechnicalView> {
  dynamic data = {};
  List<StreamSubscription> listeners = [];
  final accountName = TextEditingController();

  @override
  void initState() {
    super.initState();
    listeners.add(settings.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(wallets.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(accounts.changes.listen((changes) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    accountName.dispose();
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    print(wallets.data);
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Accounts Ovewview'));

  //ListTile innerheader() => ListTile(
  //    onTap: () {},
  //    onLongPress: () {},
  //    //leading: RavenIcon.appAvatar(),
  //    title: Text('All Accounts', style: Theme.of(context).textTheme.headline4),
  //    tileColor: Theme.of(context).bannerTheme.backgroundColor
  //    //trailing: [ import -> import page, export all accounts -> file],
  //    );

  /// set that account as current and go to import page
  Future importTo(context, account) async {
    await settings.setCurrentAccountId(account.id);
    Navigator.pushNamed(context, '/settings/import');
  }

  /// set that account as current and go to export page
  Future exportTo(context, account) async {
    await settings.setCurrentAccountId(account.id);
    Navigator.pushNamed(context, '/settings/export');
  }

  /// change the accountId for this wallet and save
  Future moveWallet(details, account) async {
    // how do we get it to redraw correctly?
    var wallet = details.data;
    await wallets.save(wallet is LeaderWallet
        ? LeaderWallet(
            id: wallet.id,
            accountId: account.id,
            encryptedSeed: wallet.encryptedSeed)
        : wallet is SingleWallet
            ? SingleWallet(
                id: wallet.id,
                accountId: account.id,
                encryptedPrivateKey: wallet.encryptedPrivateKey)
            : SingleWallet(
                // placeholder for other wallets
                id: wallet.id,
                accountId: account.id,
                encryptedPrivateKey:
                    (wallet as SingleWallet).encryptedPrivateKey));
  }

  ListView body() => ListView(
          //padding: const EdgeInsets.symmetric(horizontal: 5),
          children: <Widget>[
            for (var account in accounts.data) ...[
              DragTarget<Wallet>(
                  key: Key(account.id),
                  builder: (
                    BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected,
                  ) =>
                      wallets.byAccount.getAll(account.id).length > 0
                          ? ListTile(
                              title: Text(account.name,
                                  style: Theme.of(context).textTheme.bodyText1),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    settings.preferredAccountId == account.id
                                        ? IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.star))
                                        : IconButton(
                                            onPressed: () {
                                              settings.savePreferredAccountId(
                                                  account.id);
                                            },
                                            icon:
                                                Icon(Icons.star_outline_sharp)),
                                    IconButton(
                                        onPressed: () {
                                          importTo(context, account);
                                        },
                                        icon: Icon(Icons.add_box_outlined)),
                                    IconButton(
                                        onPressed: () {
                                          exportTo(context, account);
                                        },
                                        icon: Icon(Icons.save)),
                                  ]))
                          : ListTile(
                              title: Text(account.name,
                                  style: Theme.of(context).textTheme.bodyText1),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                        onPressed: () {
                                          importTo(context, account);
                                        },
                                        icon: Icon(Icons.add_box_outlined)),
                                    ...(accounts.data.length == 1
                                        ? [
                                            IconButton(
                                                onPressed: () async {
                                                  await accountService
                                                      .removeAccount(
                                                          account.id);
                                                },
                                                icon: Icon(Icons.delete))
                                          ]
                                        : [])
                                  ])),
                  onAcceptWithDetails: (details) async =>
                      await moveWallet(details, account)),
              for (var wallet in wallets.byAccount.getAll(account.id)) ...[
                Draggable<Wallet>(
                  key: Key(wallet.id),
                  data: wallet,
                  child: Card(
                      margin: const EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 5),
                      child: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                    '${wallet.id.substring(0, 5)}... (${wallet.kind})',
                                    style:
                                        Theme.of(context).textTheme.bodyText2),
                                TextButton.icon(
                                    icon: Icon(Icons.remove_red_eye),
                                    label: Text('show ' +
                                        (wallet is LeaderWallet
                                            ? 'seed phrase'
                                            : 'private key')),
                                    onPressed: () {})
                              ]))),
                  feedback: Card(
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                              '${wallet.id.substring(0, 5)}... (${wallet.kind})',
                              style: Theme.of(context).textTheme.bodyText2))),
                  childWhenDragging: null,
                )
              ]
            ],

            /// create new account:
            ...[
              ListTile(
                  onTap: () async {
                    var account = await accountGenerationService
                        .makeAndAwaitSaveAccount(accountName.text);
                    await settingsService.saveSetting(
                        SettingName.Account_Current, account.id);
                  },
                  title: TextField(
                      readOnly: false,
                      controller: accountName,
                      decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Create Account',
                          hintText: 'Billz')),
                  trailing:
                      Icon(Icons.add, size: 26.0, color: Colors.grey.shade800)),
              Divider(height: 20, thickness: 2, indent: 5, endIndent: 5)
            ]
          ]);
}
