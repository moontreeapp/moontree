import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';

class TransactionList extends StatefulWidget {
  final Iterable<TransactionRecord>? transactions;
  final String? msg;
  const TransactionList({this.transactions, this.msg, Key? key})
      : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  //widget.currentAccountId //  we don't rebuild on this, we're given it.
  List<StreamSubscription> listeners = [];
  late Iterable<TransactionRecord> transactions;
  bool showUSD = false;
  Rate? rateUSD;

  @override
  void initState() {
    super.initState();
    listeners.add(
        res.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      if (batchedChanges
          .where((change) =>
              change.data.address?.wallet?.accountId == Current.accountId)
          .isNotEmpty) {
        setState(() {});
      }
    }));
    listeners.add(res.rates.batchedChanges.listen((batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.data.base == res.securities.RVN &&
          change.data.quote == res.securities.USD);
      if (changes.isNotEmpty)
        setState(() {
          rateUSD = changes.first.data;
        });
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Future refresh() async {
    await services.history.produceAddressOrBalance();
    await services.rate.saveRate();
    await services.balance.recalculateAllBalances();
    setState(() {});
    // showing snackbar
    //_scaffoldKey.currentState.showSnackBar(
    //  SnackBar(
    //    content: const Text('Page Refreshed'),
    //  ),
    //);
  }

  @override
  Widget build(BuildContext context) {
    transactions = widget.transactions ?? Current.compiledTransactions;
    //? services.transaction.getTransactionRecords(
    //    account: accounts.primaryIndex.getOne(widget.currentAccountId!))
    //: Current.walletCompiledTransactions(widget.currentWalletId!)
    //    .where((transactionRecord) =>
    //        transactionRecord.fromAddress == widget.currentWalletAddress ||
    //        transactionRecord.toAddress == widget.currentWalletAddress)
    //    .toList();
    //for (var tx in transactions) print(tx);
    //print(vouts.primaryIndex.getOne(
    //    'b13feb18ae0b66f47e1606230b0a70de7d40ab52fbfc5626488136fbaa668b34:0'));
    return transactions.isEmpty
        ? components.empty.transactions(context, msg: widget.msg)
        : Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 5.0),
            child: RefreshIndicator(
              child: _transactionsView(context),
              onRefresh: () => refresh(),
            ));
  }

  ListView _transactionsView(BuildContext context) =>
      ListView(children: <Widget>[
        for (var transactionRecord in transactions) ...[
          ...[
            ListTile(
              //contentPadding:
              //    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 13),
              onTap: () => Navigator.pushNamed(
                  context, '/transaction/transaction',
                  arguments: {'transactionRecord': transactionRecord}),
              //onLongPress: _toggleUSD,
              //leading: Container(
              //    height: 40,
              //    width: 40,
              //    child: components.icons
              //        .assetAvatar(transactionRecord.security.symbol)),
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        components.text.securityAsReadable(
                            transactionRecord.value,
                            security: transactionRecord.security,
                            asUSD: showUSD),
                        style: Theme.of(context).txAmount),
                    Text(transactionRecord.formattedDatetime,
                        style: Theme.of(context).txDate),
                  ]),
              trailing: (transactionRecord.out
                  ? components.icons.out(context)
                  : components.icons.income(context)),
            ),
            Divider(indent: 16),
          ]
        ]
      ]);
}
