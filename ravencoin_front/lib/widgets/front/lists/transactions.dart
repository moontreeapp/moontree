import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/transaction.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/theme/theme.dart';

class TransactionList extends StatefulWidget {
  final Iterable<TransactionView>? transactions;
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
  late Iterable<TransactionView> transactions;
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
      final Iterable<Change<Vout>> items = batchedChanges.where(
          (Change<Vout> change) =>
              change.record.security?.symbol == widget.symbol);
      if (items.isNotEmpty) {
        print('refreshing list - vouts');
        setState(() {});
      }
    }));
    listeners.add(
        pros.rates.batchedChanges.listen((List<Change<Rate>> batchedChanges) {
      // ignore: todo
      // TODO: should probably include any assets that are in the holding of the main account too...
      final Iterable<Change<Rate>> changes = batchedChanges.where(
          (Change<Rate> change) =>
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

  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    transactions = widget.transactions ??
        services.transaction.getTransactionViewSpoof(wallet: Current.wallet);
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
                    padding:
                        const EdgeInsets.only(top: 32, left: 16, right: 16),
                    child: const Text(
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
                const SizedBox(height: 80),
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
      physics: const ClampingScrollPhysics(),
      controller: widget.scrollController,
      children: <Widget>[const SizedBox(height: 16)] +
          (services.wallet.leader.newLeaderProcessRunning ||
                  services.client.subscribe.startupProcessRunning
              ? <Widget>[
                  for (TransactionView _ in transactions) ...<Widget>[
                    components.empty.getTransactionsShimmer(context)
                  ]
                ]
              : <Widget>[
                  for (TransactionView transactionView
                      in transactions) ...<Widget>[
                    ...<Widget>[
                      ListTile(
                        //contentPadding:
                        //    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 13),
                        onTap: () => Navigator.pushNamed(
                            context, '/transaction/transaction',
                            arguments: <String, TransactionView>{
                              'transactionView': transactionView
                            }),
                        //onLongPress: _toggleUSD,
                        //leading: Container(
                        //    height: 40,
                        //    width: 40,
                        //    child: components.icons
                        //        .assetAvatar(transactionView.security.symbol)),
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  services.conversion.securityAsReadable(
                                      transactionView.relativeValue,
                                      security: transactionView.security,
                                      asUSD: showUSD),
                                  style: Theme.of(context).textTheme.bodyText1),
                              Text(
                                  '${transactionView.formattedDatetime} ${transactionView.paddedType}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText2!
                                      .copyWith(color: AppColors.black60)),
                            ]),
                        trailing: transactionView.relativeValue == 0
                            ? components.icons.fee(context)
                            : (transactionView.outgoing
                                ? components.icons.out(context)
                                : components.icons.income(context)),
                      ),
                      const Divider(indent: 16),
                    ]
                  ]
                ]) +
          <Widget>[
            Container(
              height: 80,
              color: Colors.white,
            )
          ]);
}
