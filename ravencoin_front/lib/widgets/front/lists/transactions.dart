import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/theme/theme.dart';

class TransactionList extends StatefulWidget {
  final Iterable<TransactionRecord>? transactions;
  final String? symbol;
  final String? msg;
  final ScrollController? scrollController;

  const TransactionList({
    this.transactions,
    this.symbol,
    this.msg,
    this.scrollController,
    Key? key,
  }) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  //widget.currentAccountId //  we don't rebuild on this, we're given it.
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  late Iterable<TransactionRecord> transactions;
  bool showUSD = false;
  Rate? rateUSD;
  int transactionCount = 1;

  @override
  void initState() {
    super.initState();
    listeners.add(
        pros.vouts.batchedChanges.listen((List<Change<Vout>> batchedChanges) {
      // if vouts in our account has changed...
      //var items = batchedChanges
      //    .where((change) => change.record.address?.walletId == Current.walletId);
      /// new import process doesn't save addresses till end so we don't yet
      /// know the wallet of these items, so we have to make simpler heuristic
      var items = batchedChanges
          .where((change) => change.record.security?.symbol == widget.symbol);
      if (items.isNotEmpty) {
        print('refreshing list - vouts');
        setState(() {});
      }
    }));
    listeners.add(pros.rates.batchedChanges.listen((batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      var changes = batchedChanges.where((change) =>
          change.record.base == pros.securities.RVN &&
          change.record.quote == pros.securities.USD);
      if (changes.isNotEmpty) {
        print('refreshing list - rates');
        setState(() {
          rateUSD = changes.first.record;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Future refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    transactions = widget.transactions ??
        services.transaction.getTransactionRecords(wallet: Current.wallet);
    if (transactions.isEmpty) {
      transactionCount = pros.unspents.bySymbol
          .getAll(widget.symbol ?? pros.securities.currentCoin.symbol)
          .length;
    } else {
      transactionCount = transactions.length;
    }
    return transactions.isEmpty && services.wallet.currentWallet.minerMode
        ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                Container(
                    alignment: Alignment.topCenter,
                    padding: EdgeInsets.only(
                        top: 32, left: 16, right: 16, bottom: 0),
                    child: Text(
                      '"Mine to Wallet" is enabled, so transaction history is not available. \n\nTo download your transaction history please disable "Mine to Wallet" in Settings.',
                      softWrap: true,
                      maxLines: 10,
                    )),
                if (services.developer.developerMode)
                  components.buttons.actionButtonSoft(
                    context,
                    label: 'Go to Settings',
                    link: '/settings/network/mining',
                  ),
                SizedBox(height: 80),
              ])
        : transactions.isEmpty
            //? components.empty.transactions(context, msg: widget.msg)
            ? components.empty.getTransactionsPlaceholder(context,
                scrollController: widget.scrollController!,
                count: transactionCount == 0 ? 1 : min(10, transactionCount))
            : Container(
                alignment: Alignment.center,
                child: RefreshIndicator(
                  child: _transactionsView(context),
                  onRefresh: () => refresh(),
                ));
  }

  ListView _transactionsView(BuildContext context) => ListView(
      physics: ClampingScrollPhysics(),
      controller: widget.scrollController,
      children: <Widget>[SizedBox(height: 16)] +
          (services.wallet.leader.newLeaderProcessRunning ||
                  services.client.subscribe.startupProcessRunning
              ? <Widget>[
                  for (var _ in transactions) ...[
                    components.empty.getTransactionsShimmer(context)
                  ]
                ]
              : <Widget>[
                  for (var transactionRecord in transactions) ...[
                    ...[
                      ListTile(
                        //contentPadding:
                        //    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 13),
                        onTap: () => Navigator.pushNamed(
                            context, '/transaction/transaction', arguments: {
                          'transactionRecord': transactionRecord
                        }),
                        //onLongPress: _toggleUSD,
                        //leading: Container(
                        //    height: 40,
                        //    width: 40,
                        //    child: components.icons
                        //        .assetAvatar(transactionRecord.security.symbol)),
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  services.conversion.securityAsReadable(
                                      transactionRecord.value,
                                      security: transactionRecord.security,
                                      asUSD: showUSD),
                                  style: Theme.of(context).textTheme.bodyText1),
                              Text(
                                  transactionRecord.formattedDatetime +
                                      '${!transactionRecord.isNormal ? ' | ' + transactionRecord.typeToString : ''}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(color: AppColors.black60)),
                            ]),
                        trailing: transactionRecord.value == 0
                            ? components.icons.fee(context)
                            : (transactionRecord.out
                                ? components.icons.out(context)
                                : components.icons.income(context)),
                      ),
                      Divider(indent: 16),
                    ]
                  ]
                ]) +
          [
            Container(
              height: 80,
              color: Colors.white,
            )
          ]);
}
