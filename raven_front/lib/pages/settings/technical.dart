/// clicking the Accounts name should take you to the accounts technical view
/// where you can move, rename, reorder (must be saved in new reservoir or on
/// accounts objects), delete, move wallets and view details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';

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
    listeners.add(res.settings.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(res.accounts.changes.listen((changes) {
      setState(() {});
    }));
    listeners.add(res.wallets.changes.listen((changes) {
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
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            appBar: components.headers.back(
              context,
              'Accounts',
              extraActions: [exportAllButton()],
            ),
            body: body()));
  }

  IconButton exportAllButton() => IconButton(
        onPressed: () => _exportAll(context),
        icon: components.icons.export,
      );

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
    var wallet = details.data;
    res.wallets.save(wallet is LeaderWallet
        ? LeaderWallet(
            walletId: wallet.walletId,
            accountId: account.accountId,
            encryptedEntropy: wallet.encryptedEntropy,
            cipherUpdate: wallet.cipherUpdate)
        : wallet is SingleWallet
            ? SingleWallet(
                walletId: wallet.walletId,
                accountId: account.accountId,
                encryptedWIF: wallet.encryptedWIF,
                cipherUpdate: wallet.cipherUpdate)
            : SingleWallet(
                // placeholder for other wallets
                walletId: wallet.walletId,
                accountId: account.accountId,
                encryptedWIF: (wallet as SingleWallet).encryptedWIF,
                cipherUpdate: wallet.cipherUpdate));
  }

  List<Widget> _deleteIfMany(Account account) => res.accounts.data.length > 1
      ? [
          IconButton(
              onPressed: () async {
                // doesn't delete immediately - not working until indicies work right
                await services.account.remove(account.accountId);
              },
              icon: Icon(Icons.delete))
        ]
      : [];

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
                      Text(
                          // todo use lingo keys depending on wallet type here...
                          wallet is LeaderWallet
                              ? 'HD Wallet'
                              : 'Private Key Wallet',
                          style: Theme.of(context).annotate),
                    ]),
                IconButton(
                    icon: Icon(Icons.remove_red_eye,
                        color: Theme.of(context).primaryColor),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/wallet', arguments: {
                          'wallet': wallet,
                          'secret': wallet.cipher != null
                              ? wallet.secret(wallet.cipher!)
                              : 'unknown',
                          'secretName': wallet
                              .secretType, /* todo translate this to a string */
                        }))
              ])));

//mpkrK1GLPPdqpaC8qxPVDT5bn5fkAE1UUE
//leopard web return tilt height hundred tail focus view jungle alley twenty
  ///List _getWallets(accountId) => [
  ///      for (var wallet in wallets.data)
  ///        if (wallet.accountId == accountId) wallet
  ///    ];

  ListView body() => ListView(
          //padding: const EdgeInsets.symmetric(horizontal: 5),
          children: <Widget>[
            for (var account in res.accounts.data) ...[
              DragTarget<Wallet>(
                key: Key(account.accountId),
                builder: (
                  BuildContext context,
                  List<Wallet?> accepted,
                  List<dynamic> rejected,
                ) =>
                    Column(children: <Widget>[
                  res.wallets.byAccount.getAll(account.accountId).length > 0
                      //_getWallets(account.accountId).isNotEmpty
                      ? ListTile(
                          title: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(account.name,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Text('  ${account.netName}net',
                                    style: Theme.of(context).textTheme.caption),
                              ]),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                res.settings.preferredAccountId ==
                                        account.accountId
                                    ? IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.star))
                                    : IconButton(
                                        onPressed: () {
                                          res.settings.savePreferredAccountId(
                                              account.accountId);
                                        },
                                        icon: Icon(Icons.star_outline_sharp)),
                                IconButton(
                                    onPressed: () {
                                      _importTo(context, account);
                                    },
                                    icon: components.icons.import),
                                IconButton(
                                    onPressed: () {
                                      _exportTo(context, account);
                                    },
                                    icon: components.icons.export),
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
                                    icon: components.icons.import),
                                ...(_deleteIfMany(account))
                              ])),
                  for (var wallet
                      in res.wallets.byAccount.getAll(account.accountId)) ...[
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
            ...createNewAcount(context, accountName),
          ]);

  // unused
  Future alertSuccess() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: Text('Success!'),
            content: Text('Generating Account...'),
            actions: [
              TextButton(
                  child: Text('ok'),
                  onPressed: () => Navigator.of(context).pop())
            ],
          ));
}
