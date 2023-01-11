import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/records/types/transaction_view.dart';
import 'package:client_back/server/src/protocol/comm_transaction_view.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/cubits/cubits.dart';
import 'package:client_front/theme/theme.dart';

class TransactionList extends StatefulWidget {
  final TransactionsViewCubit? cubit;
  final Iterable<TransactionView>? transactions;
  final String? symbol;
  final String? msg;
  final ScrollController? scrollController;

  const TransactionList({
    this.cubit,
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
    setState(() {
      widget.cubit?.setTransactionViews(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    transactions = widget.transactions ?? [];
    // ?? services.transaction.getTransactionViewSpoof(wallet: Current.wallet);
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
        : RefreshIndicator(
            onRefresh: () => refresh(),
            child: transactions.isEmpty
                //? components.empty.transactions(context, msg: widget.msg)
                ? components.empty.getTransactionsPlaceholder(context,
                    scrollController: widget.scrollController!,
                    count:
                        transactionCount == 0 ? 1 : min(10, transactionCount))
                : Container(
                    alignment: Alignment.center,
                    child: _transactionsView(context),
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
                  for (TransactionView transactionView in transactions)
                    if ((pros.settings.hideFees &&
                            transactionView.type != TransactionViewType.fee) ||
                        true) ...<Widget>[
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
                                        transactionView.iValueTotal,
                                        security: transactionView.security,
                                        asUSD: showUSD),
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                                Text(
                                    '${transactionView.formattedDatetime} ${transactionView.type.paddedDisplay}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2!
                                        .copyWith(color: AppColors.black60)),
                              ]),
                          trailing: transactionView.onlyFee
                              ? components.icons.fee(context)
                              : (transactionView.sentToSelf &&
                                      !transactionView.isCoin
                                  ? components.icons.outIn(context)
                                  : (transactionView.outgoing
                                      ? components.icons.out(context)
                                      : components.icons.income(context))),
                        ),
                        const Divider(indent: 16),
                      ]
                    ]
                ]) +
          <Widget>[
            /// has no effect because when this is built it is not submitting
            //if (widget.cubit?.state.isSubmitting ?? false) ...[
            //  components.empty.getTransactionsShimmer(context),
            //  const Divider(indent: 16),
            //],
            Container(
              height: 80 * 1.5,
              color: Colors.white,
            )
          ]);
}
