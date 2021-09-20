/// clicking the Accounts name should take you to the accounts technical view
/// where you can move, rename, reorder (must be saved in new reservoir or on
/// accounts objects), delete, move wallets and view details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/encrypted_entropy.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/theme/extensions.dart';
import 'package:raven_mobile/utils/wallet_kind.dart';

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
    super.initState();
    listeners.add(settings.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(accounts.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(wallets.changes.listen((changes) {
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
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
      leading: RavenButton.back(context),
      elevation: 2,
      centerTitle: false,
      actions: <Widget>[
        IconButton(onPressed: () => _exportAll(context), icon: RavenIcon.export)
      ],
      title: Text('Accounts'));

  /// set that account as current and go to import page
  void _importTo(context, account) {
    //await settings.setCurrentAccountId(account.accountId);
    Navigator.pushNamed(context, '/settings/import',
        arguments: {'accountId': account.accountId});
  }

  /// set that account as current and go to export page
  void _exportTo(context, account) {
    //await settings.setCurrentAccountId(account.accountId);
    Navigator.pushNamed(context, '/settings/export',
        arguments: {'accountId': account.accountId});
  }

  /// export all acounts ability
  void _exportAll(context) {
    Navigator.pushNamed(context, '/settings/export',
        arguments: {'accountId': 'all'});
  }

  /// change the accountId for this wallet and save
  void _moveWallet(details, account) {
    // how do we get it to redraw correctly?
    var wallet = details.data;
    //wallet.accountId = account.accountId;
    //wallets.save(wallet);
    wallets.save(wallet is LeaderWallet
        ? LeaderWallet(
            walletId: wallet.walletId,
            accountId: account.accountId,
            encryptedEntropy: wallet.encryptedEntropy)
        : wallet is SingleWallet
            ? SingleWallet(
                walletId: wallet.walletId,
                accountId: account.accountId,
                encryptedWIF: wallet.encryptedWIF)
            : SingleWallet(
                // placeholder for other wallets
                walletId: wallet.walletId,
                accountId: account.accountId,
                encryptedWIF: (wallet as SingleWallet).encryptedWIF));
  }

  List<Widget> _deleteIfMany(Account account) => accounts.data.length > 1
      ? [
          IconButton(
              onPressed: () async {
                // doesn't delete immediately - not working until indicies work right
                await accountService.removeAccount(account.accountId);
              },
              icon: Icon(Icons.delete))
        ]
      : [];

  List<Widget> _createNewAcount() => [
        SizedBox(height: 30.0),
        ListTile(
            onTap: () async {
              var account = await accountGenerationService
                  .makeSaveAccount(accountName.text);
              await settingsService.saveSetting(
                  SettingName.Account_Current, account.accountId);
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
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          '${wallet.walletId.substring(0, 6)}...${wallet.walletId.substring(wallet.walletId.length - 6, wallet.walletId.length)}',
                          style: Theme.of(context).mono),
                      Text(walletKind(wallet),
                          style: Theme.of(context).annotate),
                    ]),
                IconButton(
                    icon: Icon(Icons.remove_red_eye,
                        color: Theme.of(context).primaryColor),
                    //label: Text(
                    //    wallet is LeaderWallet ? 'seed phrase' : 'private key'),
                    onPressed: () => Navigator.pushNamed(
                            context, '/settings/wallet',
                            arguments: {
                              'address': wallet.walletId,
                              'secret':
                                  EncryptedEntropy(wallet.encrypted, cipher)
                                      .secret,
                              'secretName': wallet is LeaderWallet
                                  ? 'Mnemonic Seed'
                                  : 'Private Key',
                            }))
              ])));

  ///List _getWallets(accountId) => [
  ///      for (var wallet in wallets.data)
  ///        if (wallet.accountId == accountId) wallet
  ///    ];

  ListView body() => ListView(
          //padding: const EdgeInsets.symmetric(horizontal: 5),
          children: <Widget>[
            for (var account in accounts.data) ...[
              DragTarget<Wallet>(
                key: Key(account.accountId),
                builder: (
                  BuildContext context,
                  List<Wallet?> accepted,
                  List<dynamic> rejected,
                ) =>
                    Column(children: <Widget>[
                  wallets.byAccount.getAll(account.accountId).length > 0
                      //_getWallets(account.accountId).isNotEmpty
                      ? ListTile(
                          title: Text(account.name,
                              style: Theme.of(context).textTheme.bodyText1),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                settings.preferredAccountId == account.accountId
                                    ? IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.star))
                                    : IconButton(
                                        onPressed: () {
                                          settings.savePreferredAccountId(
                                              account.accountId);
                                        },
                                        icon: Icon(Icons.star_outline_sharp)),
                                IconButton(
                                    onPressed: () {
                                      _importTo(context, account);
                                    },
                                    icon: RavenIcon.import),
                                IconButton(
                                    onPressed: () {
                                      _exportTo(context, account);
                                    },
                                    icon: RavenIcon.export),
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
                                    icon: RavenIcon.import),
                                ...(_deleteIfMany(account))
                              ])),
                  for (var wallet
                      in wallets.byAccount.getAll(account.accountId)) ...[
                    //for (var wallet in _getWallets(account.accountId)) ...[
                    Draggable<Wallet>(
                      key: Key(wallet.walletId),
                      data: wallet,
                      child: _wallet(context, wallet),
                      feedback: _wallet(context, wallet),
                      childWhenDragging: null,
                    )
                  ]
                ]),
                onAcceptWithDetails: (details) => _moveWallet(details, account),
              ),
            ],
            ..._createNewAcount(),
          ]);
}
