/// perhaps this page should show the details of a transaction not the details of Vout or TransactionRecord...

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:raven/joins.dart';
import 'package:raven/services/transaction.dart';
import 'package:raven_mobile/theme/extensions.dart';
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
    transaction =
        transactions.primaryIndex.getOne(data['transactionRecord']!.txId);
    //address = addresses.primaryIndex.getOne(transaction!.addresses);
    var metadata = transaction!.memo != null && transaction!.memo != '';
    print('transaction: $transaction');
    print('vins: ${transaction!.vins}');
    print('vouts: ${transaction!.vouts}');
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

                    // should be in list of Vins and Vouts, not at transaction level
                    //RavenIcon.assetAvatar(transaction!.security.symbol),
                    //SizedBox(height: 15.0),
                    //Text(transaction!.security.symbol,
                    //    style: Theme.of(context).textTheme.headline3),
                    //SizedBox(height: 15.0),

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
                child: Text('Transaction ID: ${transaction!.txId}',
                    style: TextStyle(color: Theme.of(context).primaryColor)),
                onTap: () => launch(
                    'https://rvnt.cryptoscope.io/tx/?txid=${transaction!.txId}')),
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
                  leading: RavenIcon.assetAvatar(
                      vin.vout!.asset ?? vin.vout!.security!.symbol),
                  title: Text(vin.vout!.security!.symbol,
                      style: Theme.of(context).textTheme.bodyText2),
                  trailing: Text(RavenText.securityAsReadable(
                      vin.vout?.value ?? -1,
                      symbol: vin.vout?.security?.symbol ?? 'RVN')),
                )
              ],
            ],
            Divider(thickness: 1.0, color: Colors.black),

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
                leading:
                    RavenIcon.assetAvatar(vout.asset ?? vout.security!.symbol),
                title: Text(vout.security!.symbol),
                trailing: Text(RavenText.securityAsReadable(
                    vout.amount ?? vout.value,
                    symbol: vout.security!.symbol)),
              )
            ],
          ])
        ]),
      ]);
}

/*
remaining issues:
1. transactions should not be associated with addresses, Vins and Vouts should be
2. we need to capture all the vouts for all vins that don't have a vout (don't need to capture entire transaction (don't need vins))
3. make sure block reservoir is working


I think we should have Vins associated with an address. 
upon new address go get all the transactions for those but don't purge them by transaction, purge by vins and vouts...
then have address.vins and address.vouts and vin.address and vout.address joins
and have address.transactions (all transactions that contain the vins and outs)
never purge transactions
Also have a waiter watching for new transactions. 
*/
