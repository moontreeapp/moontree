import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/utils/data.dart';

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
  TransactionRecord? transactionRecord;
  Transaction? transaction;

  @override
  void initState() {
    super.initState();
    listeners.add(res.blocks.changes.listen((changes) {
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
    transactionRecord = data['transactionRecord'];
    transaction = transactionRecord!.transaction;
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    var metadata = transaction!.memo != null && transaction!.memo != '';
    return DefaultTabController(
        length: metadata ? 2 : 1,
        child: Scaffold(
          //appBar: header(metadata),
          body: body(metadata),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  int? getBlocksBetweenHelper({Transaction? tx, Block? current}) {
    tx = tx ?? transaction!;
    current = current ?? res.blocks.latest;
    return (current != null && tx.height != null)
        ? current.height - tx.height!
        : null;
  }

  String getDateBetweenHelper() => 'Date: ' + transaction!.formattedDatetime;
  //(getBlocksBetweenHelper() != null
  //    ? formatDate(
  //        DateTime.now().subtract(Duration(
  //          days: (getBlocksBetweenHelper()! / 1440).floor(),
  //          hours:
  //              (((getBlocksBetweenHelper()! / 1440) % 1440) / 60).floor(),
  //        )),
  //        [MM, ' ', d, ', ', yyyy])
  //    : 'unknown');

  String getConfirmationsBetweenHelper() =>
      'Confirmations: ' +
      (getBlocksBetweenHelper() != null
          ? getBlocksBetweenHelper().toString()
          : 'unknown');

  PreferredSize header(bool metadata) => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.20),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: components.buttons.back(context),
          actions: <Widget>[
            components.status,
            indicators.process,
            indicators.client,
          ],
          title: Text('Transaction'),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 22),
                    Text(
                      transactionRecord!.out ? 'Sent' : 'Received',
                    ),
                    Text(
                      components.text
                          .securityAsReadable(transactionRecord!.value,
                              symbol: transactionRecord!.security.symbol)
                          .toString(),
                    )
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
            /// tx ---------------------------------------------------------
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
                child: Wrap(children: [
                  Text('Transaction ID: '),
                  Text('${transaction!.id}',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                ]),
                onTap: () => launch(
                    'https://rvnt.cryptoscope.io/tx/?txid=${transaction!.id}')),
            SizedBox(height: 15.0),

            /// vin --------------------------------------------------------
            ...transactionRecord!.totalIn > 0
                ? [
                    SizedBox(height: 5.0),
                    Text('Sent', style: Theme.of(context).textTheme.caption),
                    ListTile(
                      onTap: () {/* copy the amount to clipboard */},
                      onLongPress: () {},
                      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                      leading: Container(
                          height: 50,
                          width: 50,
                          child: components.icons
                              .assetAvatar(transactionRecord!.security.symbol)),
                      title: Text(transactionRecord!.security.symbol),
                      trailing: Text(components.text.securityAsReadable(
                          transactionRecord!.totalIn,
                          security: transactionRecord!.security)),
                    ),
                  ]
                : [],

            /// vout -------------------------------------------------------
            ...transactionRecord!.totalOut > 0
                ? [
                    SizedBox(height: 15.0),
                    Divider(thickness: 1.0, color: Colors.grey.shade800),
                    SizedBox(height: 15.0),
                    SizedBox(height: 5.0),
                    Text('Received',
                        style: Theme.of(context).textTheme.caption),
                    ListTile(
                      onTap: () {/* copy amount to clipboard */},
                      onLongPress: () {},
                      contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                      leading: Container(
                          height: 50,
                          width: 50,
                          child: components.icons
                              .assetAvatar(transactionRecord!.security.symbol)),
                      title: Text(transactionRecord!.security.symbol),
                      trailing: Text(components.text.securityAsReadable(
                          transactionRecord!.totalOut,
                          security: transactionRecord!.security)),
                    ),
                  ]
                : [],
          ])
        ]),
      ]);
}
