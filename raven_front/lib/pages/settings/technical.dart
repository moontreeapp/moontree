/// clicking the Accounts name should take you to the accounts technical view
/// where you can move, rename, reorder (must be saved in new reservoir or on
/// accounts objects), delete, move wallets and view details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/theme/extensions.dart';

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
  const TechnicalView() : super();

  @override
  _TechnicalViewState createState() => _TechnicalViewState();
}

class _TechnicalViewState extends State<TechnicalView> {
  List<StreamSubscription> listeners = [];
  final accountName = TextEditingController();

  @override
  void initState() {
    listeners.add(settings.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(accounts.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(wallets.changes.listen((changes) {
      setState(() {});
    }));
    super.initState();
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
    // indicies not updated (removed) yet
    //print(accounts.data);
    //print(wallets.data);
    //var hierarchy = [
    //  for (var account in accounts.data) ...[
    //    account.id,
    //    for (var wallet in wallets.byAccount.getAll(account.id)) ...[
    //      wallet.id,
    //    ]
    //  ]
    //];
    //print(hierarchy);

    // work around
    print(accounts.data);
    print(wallets.data);
    var hierarchy = [
      for (var account in accounts.data) ...[
        account.id,
        for (var wallet in wallets.data) ...[
          if (wallet.accountId == account.id) wallet.id,
        ]
      ]
    ];
    print(hierarchy);
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      title: Text('Accounts Ovewview'));

  /// set that account as current and go to import page
  Future _importTo(context, account) async {
    await settings.setCurrentAccountId(account.id);
    Navigator.pushNamed(context, '/settings/import');
  }

  /// set that account as current and go to export page
  Future _exportTo(context, account) async {
    await settings.setCurrentAccountId(account.id);
    Navigator.pushNamed(context, '/settings/export');
  }

  /// change the accountId for this wallet and save
  void _moveWallet(details, account) {
    // how do we get it to redraw correctly?
    var wallet = details.data;
    wallets.save(wallet is LeaderWallet
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

  List<Widget> _deleteIfMany(Account account) => accounts.data.length > 1
      ? [
          IconButton(
              onPressed: () async {
                // doesn't delete immediately - not working until indicies work right
                await accountService.removeAccount(account.id);
              },
              icon: Icon(Icons.delete))
        ]
      : [];

  List<Widget> _createNewAcount() => [
        SizedBox(height: 30.0),
        ListTile(
            onTap: () async {
              var account = await accountGenerationService
                  .makeAndAwaitSaveAccount(accountName.text);
              await settingsService.saveSetting(
                  SettingName.Account_Current, account.id);
              accountName.text = '';
            },
            title: TextField(
                readOnly: false,
                controller: accountName,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Create Account',
                    hintText: 'Billz')),
            trailing: Icon(Icons.add, size: 26.0, color: Colors.grey.shade800)),
      ];

  Card _wallet(BuildContext context, Wallet wallet) => Card(
      margin: const EdgeInsets.fromLTRB(40.0, 0.0, 10.0, 5),
      child: Padding(
          padding: EdgeInsets.fromLTRB(10.0, 5.0, 5.0, 5.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '${wallet.id.substring(0, 6)}...${wallet.id.substring(wallet.id.length - 6, wallet.id.length)}',
                          style: Theme.of(context).mono),
                      Text('${wallet.kind}', style: Theme.of(context).annotate),
                    ]),
                TextButton.icon(
                    icon: Icon(Icons.remove_red_eye),
                    label: Text(
                        wallet is LeaderWallet ? 'seed phrase' : 'private key'),
                    onPressed: () => Navigator.pushNamed(
                            context, '/settings/wallet',
                            arguments: {
                              'address': wallet.id,
                              'secret': wallet.secret,
                              'secretName': wallet is LeaderWallet
                                  ? 'Seed Phrase'
                                  : 'Private Key',
                            }))
              ])));

  List _getWallets(accountId) => [
        for (var wallet in wallets.data)
          if (wallet.accountId == accountId) wallet
      ];

  ListView body() => ListView(
          //padding: const EdgeInsets.symmetric(horizontal: 5),
          children: <Widget>[
            for (var account in accounts.data) ...[
              DragTarget<Wallet>(
                  key: Key(account.id),
                  builder: (
                    BuildContext context,
                    List<Wallet?> accepted,
                    List<dynamic> rejected,
                  ) =>
                      //wallets.byAccount.getAll(account.id).length > 0
                      _getWallets(account.id).isNotEmpty
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
                                          _importTo(context, account);
                                        },
                                        icon: Icon(Icons.add_box_outlined)),
                                    IconButton(
                                        onPressed: () {
                                          _exportTo(context, account);
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
                                          _importTo(context, account);
                                        },
                                        icon: Icon(Icons.add_box_outlined)),
                                    ...(_deleteIfMany(account))
                                  ])),
                  onAcceptWithDetails: (details) =>
                      _moveWallet(details, account)),
              //for (var wallet in wallets.byAccount.getAll(account.id)) ...[
              for (var wallet in _getWallets(account.id)) ...[
                Draggable<Wallet>(
                  key: Key(wallet.id),
                  data: wallet,
                  child: _wallet(context, wallet),
                  feedback: _wallet(context, wallet),
                  childWhenDragging: null,
                )
              ]
            ],
            ..._createNewAcount(),
          ]);
}
