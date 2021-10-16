import 'dart:async';

import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';
import 'package:raven_mobile/components/text.dart';
import 'package:raven_mobile/utils/utils.dart';

class TransactionPage extends StatefulWidget {
  final dynamic data;
  const TransactionPage({this.data}) : super();

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  dynamic data = {};
  Address? address;
  List<StreamSubscription> listeners = [];
  Transaction? transaction;

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
    transaction = transactions.primaryIndex.getOne(data['transaction']!.hash);
    address = addresses.primaryIndex.getOne(transaction!.scripthash);
    var metadata = transaction!.memo != null && transaction!.memo != '';
    return DefaultTabController(
        length: metadata ? 2 : 1,
        child: Scaffold(
            appBar: header(metadata),
            body: body(metadata),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  int? getBlocksBetweenHelper({Transaction? tx, Block? current}) {
    tx = tx ?? transaction!;
    current = current ?? blocks.latest; //Block(height: 0);
    return current != null ? current.height - tx!.height : null;
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
                    // indicates transaction should be a vout...
                    RavenIcon.assetAvatar(transaction!.security.symbol),
                    SizedBox(height: 15.0),
                    Text(transaction!.security.symbol,
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
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                      text: RavenText.securityAsReadable(transaction!.value,
                          symbol: transaction!.security.symbol)),
                ),

                /// see fee and other details on cryptoscope
                //Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                //  Text('fee',
                //      style: TextStyle(color: Theme.of(context).disabledColor)),
                //  Text('0.01397191 RVN',
                //      style: TextStyle(color: Theme.of(context).disabledColor)),
                //]),

                /// hide note if none was saved
                ...(transaction!.note != ''
                    ? [
                        SizedBox(height: 15.0),
                        TextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: transaction!.note),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Note',
                                hintText: 'Note to Self')),
                      ]
                    : []),

                /// allow user to copy the ipfs hash here, see results on tab
                ...(metadata
                    ? [
                        SizedBox(height: 15.0),
                        TextField(
                            readOnly: true,
                            controller:
                                TextEditingController(text: transaction!.memo),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                                border: UnderlineInputBorder(),
                                labelText: 'Memo',
                                hintText: 'IPFS hash')),
                      ]
                    : []),
                SizedBox(height: 15.0),
                InkWell(
                    child: Text('id: ${transaction!.txId}',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor)),
                    onTap: () => launch(
                        'https://rvnt.cryptoscope.io/tx/?txid=${transaction!.txId}')),
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
