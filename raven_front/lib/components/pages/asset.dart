import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/pages/transaction.dart';
import 'package:raven_mobile/styles.dart';

PreferredSize header(context) => PreferredSize(
    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
    child: AppBar(
        backgroundColor: RavenColor().appBar,
        elevation: 2,
        centerTitle: false,
        leading: RavenButton().back(context),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: RavenButton().settings(context))
        ],
        title: RavenText('Magic Musk').h2,
        flexibleSpace: Container(
            color: RavenColor().appBar,
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              RavenIcon().getAssetAvatar('Magic Musk'),
              RavenText('50').h1,
              RavenText('\$654.02').h3,
            ])),
        bottom: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
                labelColor: RavenColor().offWhite,
                indicatorColor: Colors.grey[400],
                tabs: [Tab(text: 'Transactions'), Tab(text: 'Metadata')]))));

/// get metadata from chain or something, store it... need a new reservoir...
/// interpret it correctly if it is in a recognizable format,
/// else present file download option
ListView? _metadataView(context, data) {
  return ListView(children: [Image(image: AssetImage('assets/magicmusk.png'))]);
  //return null;
}

/// filter down to just the transactions for this asset
ListView _transactionsView(context, data) {
  var txs = <Widget>[];
  for (var transaction in data['transactions'][data['account']]) {
    if (transaction['asset'] == 'Magic Musk') {
      txs.add(ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Transaction()),
            );
          },
          onLongPress: () {/* convert all values to USD and back */},
          title:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            RavenText(transaction['asset']).name,
            (transaction['direction'] == 'in'
                ? RavenIcon().income
                : RavenIcon().out),
          ]),
          trailing: (transaction['direction'] == 'in'
              ? RavenText(transaction['amount'].toString()).good
              : RavenText(transaction['amount'].toString()).bad),
          leading: RavenIcon().getAssetAvatar(transaction['asset'])));
    }
  }
  return ListView(children: txs);
}

Container _emptyMessage({IconData? icon, String? name}) => Container(
    color: Colors.grey,
    alignment: Alignment.center,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon ?? Icons.description, size: 50.0, color: Colors.grey[100]),
      RavenText('\nMagic Musk $name empty.\n').h2,
    ]));

/// returns a list of holdings and transactions or empty messages
TabBarView transactionsMetadataView(context, data) => TabBarView(children: [
      data['transactions'][data['account']].isEmpty
          ? _emptyMessage(icon: Icons.public, name: 'transactions')
          : _transactionsView(context, data),
      _metadataView(context, data) ??
          _emptyMessage(icon: Icons.description, name: 'metadata'),
    ]);

/// different from home.sendReceiveButtons because it prefills the chosen token
/// receive works the same
Row sendReceiveButtons(context) =>
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      RavenButton().receive(context),
      RavenButton().send(context, asset: 'Magic Musk'),
    ]);
