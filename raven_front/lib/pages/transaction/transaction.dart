/// perhaps this page should show the details of a transaction not the details of Vout or TransactionRecord...

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
import 'package:raven_front/utils/utils.dart';

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
    transaction = transactions.primaryIndex
        .getOne(data['transactionRecord']!.transactionId);
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    var metadata = transaction!.memo != null && transaction!.memo != '';
    return DefaultTabController(
        length: metadata ? 2 : 1,
        child: Scaffold(
          appBar: header(metadata),
          body: body(metadata),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  int? getBlocksBetweenHelper({Transaction? tx, Block? current}) {
    tx = tx ?? transaction!;
    current = current ?? blocks.latest;
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
                    Text(data['transactionRecord']!.out ? 'Sent' : 'Received',
                        style: Theme.of(context).textTheme.headline5),
                    Text(
                        components.text
                            .securityAsReadable(
                                data['transactionRecord']!.value,
                                symbol: data['transactionRecord']!
                                        .security
                                        ?.symbol ??
                                    'RVN')
                            .toString(),
                        style: Theme.of(context).textTheme.headline5)
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
                  Text('${transaction!.transactionId}',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight)),
                ]),
                onTap: () => launch(
                    'https://rvnt.cryptoscope.io/tx/?txid=${transaction!.transactionId}')),
            SizedBox(height: 15.0),

            /// vin --------------------------------------------------------
            for (Vin vin in transaction!.vins) ...[
              if (vin.vout != null) ...[
                SizedBox(height: 5.0),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('from: ',
                          style: Theme.of(context).textTheme.caption),
                      SelectableText(vin.vout?.toAddress ?? 'unkown',
                          style: Theme.of(context).annotate),
                    ]),
                ListTile(
                  onTap: () {/* copy the amount to clipboard */},
                  onLongPress: () {},
                  contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                  leading: Container(
                      height: 50,
                      width: 50,
                      child: components.icons
                          .assetAvatar(vin.vout!.security!.symbol)),
                  title: Text(vin.vout!.security!.symbol,
                      style: Theme.of(context).textTheme.bodyText2),
                  trailing: Text(components.text.securityAsReadable(
                      vin.vout?.securityValue(
                              security: securities.primaryIndex.getOne(
                                  vin.vout?.securityId ?? 'RVN:Crypto')) ??
                          -1,
                      symbol: vin.vout?.security?.symbol ?? 'RVN')),
                  //vin.vout?.rvnValue ?? vin.vout?.assetValue ?? -1,
                  //symbol: vin.vout?.security?.symbol ?? 'RVN')),
                )
              ],
            ],
            SizedBox(height: 15.0),
            Divider(thickness: 1.0, color: Colors.grey.shade800),

            /// vout -------------------------------------------------------
            SizedBox(height: 15.0),
            for (Vout vout in transaction!.vouts) ...[
              SizedBox(height: 5.0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('to: ', style: Theme.of(context).textTheme.caption),
                SelectableText(vout.toAddress,
                    style: Theme.of(context).annotate),
              ]),
              ListTile(
                onTap: () {/* copy amount to clipboard */},
                onLongPress: () {},
                contentPadding: EdgeInsets.only(left: 0.0, right: 0.0),
                leading: components.icons.assetAvatar(vout.security!.symbol),
                title: Text(vout.security!.symbol),
                trailing: Text(components.text.securityAsReadable(
                    vout.assetValue ?? vout.rvnValue,
                    symbol: vout.security!.symbol)),
              )
            ],
          ])
        ]),
      ]);
}
