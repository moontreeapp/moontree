/// clicking the Accounts name should take you to the accounts technical view
/// where you can delete or rename accounts, move wallets and view their details.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/utils/utils.dart';

/// make our own 2-layer hierarchy view
/// use draggable to move things between the levels:
///
/// view Balances? should be easy balances are saved by wallet and by account...
///
/// header [ import -> import page, export all accounts -> file]
/// spacer (drag target) [ reorder accounts by dragging ]
/// account [ renamable by click ] (drag target) [ delete, import-> set that account as current and go to import page, export -> file ]
///   wallet [ type and id... ] (draggable) [ delete, view details?, export -> show private key or seed phrase ]
///
/// account order will be saved in settings:
/// settings.accountOrder List
/// settings.saveAccountOrder(List<String> accountIds)

class TechnicalView extends StatefulWidget {
  final dynamic data;
  const TechnicalView({this.data}) : super();

  @override
  _TechnicalViewState createState() => _TechnicalViewState();
}

class _TechnicalViewState extends State<TechnicalView> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
    settings.changes.listen((changes) {
      setState(() {});
    });
    wallets.changes.listen((changes) {
      setState(() {});
    });
    accounts.changes.listen((changes) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
        leading: RavenButton.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text('Technical View'),
      );

  ReorderableListView body() {
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      header: _header(),
      children: <Widget>[
        for (var account in accounts.data) ...[
          // just account
          //ListTile(
          //  key: Key(account.id),
          //  //onTap: () {},
          //  //onLongPress: () {/* rename? */},
          //  //leading: RavenIcon.accountAvatar(), //alternative Icon(Icons.more_horiz) to show movable
          //  title: Text(
          //    account.name,
          //    //style: Theme.of(context).textTheme.bodyText1
          //  ),
          //  //trailing:  (drag target) [ delete, import-> set that account as current and go to import page, export -> file ],
          //)
          DragTarget<Wallet>(
              key: Key(account.id),
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) =>
                  ListTile(title: Text(account.name)),
              onAcceptWithDetails: (details) {
                /// change the accountId for this wallet and save
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
                                id: wallet.id,
                                accountId: account.id,
                                encryptedPrivateKey: (wallet as SingleWallet)
                                    .encryptedPrivateKey) // placeholder for other wallets
                    );
              }),

          for (var wallet in wallets.byAccount.getAll(account.id)) ...[
            /// for moving a wallet to a different account...
            Draggable<Wallet>(
                key: Key(wallet.id),
                data: wallet,
                child: ListTile(
                  onTap: () {/*view details?*/},
                  onLongPress: () {},
                  leading: RavenIcon.walletAvatar(
                      wallet), //alternative Icon(Icons.more_horiz) to show movable
                  title: Text(
                      wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                      style: Theme.of(context).textTheme.bodyText2),
                  //trailing: [ delete, view details?, export -> show private key or seed phrase ],
                ),
                feedback: ListTile(
                  onTap: () {/*view details?*/},
                  onLongPress: () {},
                  leading: RavenIcon.walletAvatar(
                      wallet), //alternative Icon(Icons.more_horiz) to show movable
                  title: Text(
                      wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                      style: Theme.of(context).textTheme.bodyText2),
                  //trailing: [ delete, view details?, export -> show private key or seed phrase ],
                ),
                childWhenDragging: ListTile(
                  onTap: () {/*view details?*/},
                  onLongPress: () {},
                  leading: RavenIcon.walletAvatar(
                      wallet), //alternative Icon(Icons.more_horiz) to show movable
                  title: Text(
                      wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                      style: Theme.of(context).textTheme.bodyText2),
                  // without childWhenDragging ... if we place it in an illegal location what happens?
                ))
          ]
        ]
      ],
      onReorder: (int oldIndex, int newIndex) {
        //  var order = settings.accountOrder;
        //  var movedId = order[oldIndex];
        //  var pushId = order[newIndex];
        //  order.remove(movedId);
        //  order = [
        //    for (var item in order) ...[
        //      if (item == pushId) ...[movedId, item] else item
        //    ]
        //  ];
        //  settings.saveAccountOrder(order);
      },
    );

    //Column(children: <Widget>[
    //  _heading(),
    //  _accounts(),
    //]);
  }

  ListTile _header() => ListTile(
        onTap: () {},
        onLongPress: () {},
        leading: RavenIcon.appAvatar(),
        title:
            Text('All Accounts', style: Theme.of(context).textTheme.bodyText1),
        //trailing: [ import -> import page, export all accounts -> file],
      );

  //ListView _accounts() => ListView(shrinkWrap: true, children: <Widget>[
  List<Widget> _accounts() => <Widget>[
        for (var account in accounts.data) ...[
          DragTarget<Account>(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) =>
                  ListTile(
                    onTap: () {},
                    onLongPress: () {/* rename? */},
                    leading: RavenIcon.accountAvatar(),
                    title: Text('---'),
                  ),
              onAcceptWithDetails: (details) {
                //  var order = settings.accountOrder;
                //  var movedAccount = details.data;
                //  order.remove(movedAccount.id);
                //  order = [
                //    for (var item in order) ...[
                //      if (item == account.id) ...[movedAccount.id, item] else item
                //    ]
                //  ];
                //  settings.saveAccountOrder(order);
              }),
          DragTarget<Wallet>(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) =>
                  Draggable<Account>(
                      data: account,
                      child: ListTile(
                        onTap: () {},
                        onLongPress: () {/* rename? */},
                        leading: RavenIcon
                            .accountAvatar(), //alternative Icon(Icons.more_horiz) to show movable
                        title: Text(account.name,
                            style: Theme.of(context).textTheme.bodyText1),
                        //trailing:  (drag target) [ delete, import-> set that account as current and go to import page, export -> file ],
                      ),
                      feedback: ListTile(
                        key: Key(account.id),
                        onTap: () {},
                        onLongPress: () {/* rename? */},
                        leading: RavenIcon
                            .accountAvatar(), //alternative Icon(Icons.more_horiz) to show movable
                        title: Text(account.name,
                            style: Theme.of(context).textTheme.bodyText1),
                        //trailing:  (drag target) [ delete, import-> set that account as current and go to import page, export -> file ],
                      )),
              onAcceptWithDetails: (details) {
                /// change the accountId for this wallet and save
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
                                id: wallet.id,
                                accountId: account.id,
                                encryptedPrivateKey: (wallet as SingleWallet)
                                    .encryptedPrivateKey) // placeholder for other wallets
                    );
              }),
          //_wallets(account),
        ]
      ];
  //);

  ListView _wallets(account) => ListView(shrinkWrap: true, children: <Widget>[
        for (var wallet in wallets.byAccount.getAll(account.id)) ...[
          /// for moving a wallet to a different account...
          Draggable<Wallet>(
              data: wallet,
              child: ListTile(
                onTap: () {/*view details?*/},
                onLongPress: () {},
                leading: RavenIcon.walletAvatar(
                    wallet), //alternative Icon(Icons.more_horiz) to show movable
                title: Text(
                    wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                    style: Theme.of(context).textTheme.bodyText2),
                //trailing: [ delete, view details?, export -> show private key or seed phrase ],
              ),
              feedback: ListTile(
                onTap: () {/*view details?*/},
                onLongPress: () {},
                leading: RavenIcon.walletAvatar(
                    wallet), //alternative Icon(Icons.more_horiz) to show movable
                title: Text(
                    wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                    style: Theme.of(context).textTheme.bodyText2),
                //trailing: [ delete, view details?, export -> show private key or seed phrase ],
              ),
              childWhenDragging: ListTile(
                onTap: () {/*view details?*/},
                onLongPress: () {},
                leading: RavenIcon.walletAvatar(
                    wallet), //alternative Icon(Icons.more_horiz) to show movable
                title: Text(
                    wallet.kind + ' ' + wallet.id.substring(0, 5) + '...',
                    style: Theme.of(context).textTheme.bodyText2),
                // without childWhenDragging ... if we place it in an illegal location what happens?
              ))
        ]
      ]);
}
