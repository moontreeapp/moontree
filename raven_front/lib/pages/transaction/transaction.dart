import 'dart:async';

import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/utils/utils.dart';

class Transaction extends StatefulWidget {
  final dynamic data;
  const Transaction({this.data}) : super();

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  dynamic data = {};
  Address? address;
  List<StreamSubscription> listeners = [];
  History? history;

  @override
  void initState() {
    super.initState();
    listeners.add(blocks.changes.listen((changes) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    history = histories.primaryIndex.getOne(data['transaction']!.hash);
    address = addresses.primaryIndex.getOne(history!.scripthash);
    var metadata = history!.memo != null;
    return DefaultTabController(
        length: metadata ? 2 : 1,
        child: Scaffold(
            appBar: header(metadata),
            body: body(metadata),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  int? getBlocksBetweenHelper({History? transaction, Block? current}) {
    transaction = transaction ?? history!;
    current = current ?? blocks.latest; //Block(height: 0);
    return current != null && transaction != null
        ? current.height - transaction.height
        : null;
  }

  String getDateBetweenHelper() =>
      'Date: ' +
      (getBlocksBetweenHelper() != null
          ? formatDate(
              DateTime.now().subtract(Duration(
                days: (getBlocksBetweenHelper()! / 1440).floor(),
                hours:
                    (((getBlocksBetweenHelper()! / 1440) % 1440) / 60).floor(),
              )),
              [MM, ' ', d, ', ', yyyy])
          : 'unknown');

  String getConfirmationsBetweenHelper() =>
      'Confirmaitons: ' +
      (getBlocksBetweenHelper() != null
          ? getBlocksBetweenHelper().toString()
          : 'unknown');

  PreferredSize header(bool metadata) => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: RavenButton.back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton.settings(context, () {
                  setState(() {});
                }))
          ],
          title: Text('Transaction'),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.0),
                    RavenIcon.assetAvatar(history!.security.symbol),
                    SizedBox(height: 15.0),
                    Text(history!.security.symbol,
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 15.0),
                    Text('Received',
                        style: Theme.of(context).textTheme.headline5),
                  ])),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(tabs: [
                Tab(text: 'Details'),
                ...(metadata ? [Tab(text: 'Memo')] : [])
              ]))));

  TabBarView body(bool metadata) => TabBarView(children: [
        ListView(shrinkWrap: true, padding: EdgeInsets.all(20.0), children: <
            Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getDateBetweenHelper(),
                style: TextStyle(color: Theme.of(context).disabledColor)),
            Text(getConfirmationsBetweenHelper(),
                style: TextStyle(color: Theme.of(context).disabledColor)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
              Widget>[
            SizedBox(height: 15.0),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'To',
                  hintText: 'Address'),
              controller:
                  TextEditingController(text: address?.address ?? 'unkown'),
            ),
            SizedBox(height: 15.0),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount',
                  hintText: 'Quantity'),
              controller: TextEditingController(
                  text: RavenText.securityAsReadable(history!.value,
                      symbol: history!.security.symbol)),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('fee',
                  style: TextStyle(color: Theme.of(context).disabledColor)),
              Text('0.01397191 RVN',
                  style: TextStyle(color: Theme.of(context).disabledColor)),
            ]),

            /// hide note if none was saved
            ...(history!.note != ''
                ? [
                    SizedBox(height: 15.0),
                    TextField(
                        readOnly: true,
                        controller: TextEditingController(text: history!.note),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Note',
                            hintText: 'Note to Self')),
                    SizedBox(height: 15.0),
                  ]
                : []),

            /// allow user to copy the ipfs hash here, see results on tab
            ...(metadata
                ? [
                    TextField(
                        readOnly: true,
                        controller: TextEditingController(text: history!.memo),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Memo',
                            hintText: 'IPFS hash')),
                    SizedBox(height: 15.0)
                  ]
                : []),
            Text('id: ' + history!.hash,
                style: TextStyle(color: Theme.of(context).disabledColor)),
            SizedBox(height: 15.0),
            Text(address != null ? 'wallet: ' + address!.walletId : '',
                style: Theme.of(context).textTheme.caption),
            Text(
                address != null
                    ? 'account: ' + address!.wallet!.account!.name
                    : '',
                style: Theme.of(context).textTheme.caption),
          ])
        ]),
        ...(metadata ? [Text('None')] : [])
      ]);
}
