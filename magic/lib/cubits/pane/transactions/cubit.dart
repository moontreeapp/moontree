import 'dart:collection';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/rate.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/utils/range.dart';
import 'package:magic/services/calls/mempool.dart';
import 'package:magic/services/calls/transactions.dart';
import 'package:magic/services/services.dart';
import 'package:magic/utils/dart.dart';

part 'state.dart';

class TransactionsCubit extends UpdatableCubit<TransactionsState> {
  TransactionsCubit() : super(const TransactionsState());
  bool reachedEnd = false;
  @override
  String get key => 'transactions';
  @override
  void reset() => emit(const TransactionsState());
  @override
  void setState(TransactionsState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);

  @override
  void update({
    bool? active,
    bool? disposed,
    Holding? asset,
    // should be Transaction then we convert to a display object in the ui or state.
    List<TransactionDisplay>? mempool,
    List<TransactionDisplay>? transactions,
    Widget? child,
    bool? clearing,
    bool? isSubmitting,
  }) {
    emit(TransactionsState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      mempool: mempool ?? state.mempool,
      transactions: transactions ?? state.transactions,
      child: child ?? state.child,
      clearing: clearing ?? state.clearing,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  Future<void> populateAllTransactions({
    Holding? holding,
    int? fromHeight,
  }) async {
    holding = holding ?? cubits.holding.state.holding;
    update(isSubmitting: true);
    await populateTransactions(holding: holding, fromHeight: fromHeight);
    await populateMempoolTransactions(holding: holding);
    print('${holding.symbol} ${cubits.holding.state.holding.symbol}');
    if (holding.symbol != cubits.holding.state.holding.symbol) {
      return;
    }
    update(isSubmitting: false);
  }

  Future<void> populateTransactions({Holding? holding, int? fromHeight}) async {
    // remember to order by currency first, amount second, alphabetical third
    if (holding == null || reachedEnd) {
      //update(transactions: [], isSubmitting: false);
      return;
    }
    final isSubmitting = state.isSubmitting;
    if (!isSubmitting) {
      update(isSubmitting: true);
    }
    await Future.delayed(fadeDuration * 10);
    print('populating transactions: ${state.transactions.length}');
    final replace = holding != cubits.holding.state.holding;
    // get the max transaction.height from the list of transactions
    fromHeight = fromHeight ??
        (state.transactions.isNotEmpty
            ? state.transactions
                .map((transaction) => transaction.height)
                .reduce((a, b) => a < b ? a : b)
            : null);
    print(
        'asking from: ${fromHeight ?? (state.transactions.isNotEmpty ? state.transactions.length : null)}');
    final transactions = _sort(_newRateThese(
        rate: holding.isRavencoin
            ? rates.rvnUsdRate
            : holding.isEvrmore
                ? rates.evrUsdRate
                : null,
        transactions: await TransactionHistoryCall(
          derivationWallets: cubits.keys.master.derivationWallets,
          keypairWallets: cubits.keys.master.keypairWallets,
          blockchain: holding.blockchain,
          height: fromHeight,
          symbol: holding.symbol,
        ).call()));
    if (transactions.isEmpty || transactions == state.transactions) {
      reachedEnd = true;
      update(isSubmitting: isSubmitting);
      return;
    }
    print('${holding.symbol} ${cubits.holding.state.holding.symbol}');
    if (holding.symbol != cubits.holding.state.holding.symbol) {
      return;
    }
    final newTransactions = combineWithoutDuplicates<TransactionDisplay>(
        replace ? <TransactionDisplay>[] : state.transactions, transactions);
    newTransactions.sort((a, b) => b.height.compareTo(a.height));
    if (newTransactions.length == state.transactions.length) {
      reachedEnd = true;
    }
    update(
      transactions: newTransactions,
      isSubmitting: isSubmitting,
    );
    cubits.pane.update(
      active: true,
      //height: screen.pane.midHeight,
      //max: screen.pane.maxHeightPercent,
      max: state.transactions.length > 6
          ? screen.pane.maxHeightPercent
          : screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
  }

  Future<void> populateMempoolTransactions({
    Holding? holding,
  }) async {
    final isSubmitting = state.isSubmitting;
    if (!isSubmitting) {
      update(isSubmitting: true);
    }
    holding ??= cubits.holding.state.holding;
    final transactions = _sort(_newRateThese(
        rate: holding.isRavencoin
            ? rates.rvnUsdRate
            : holding.isEvrmore
                ? rates.evrUsdRate
                : null,
        transactions: await TransactionMempoolCall(
          derivationWallets: cubits.keys.master.derivationWallets,
          keypairWallets: cubits.keys.master.keypairWallets,
          blockchain: holding.blockchain,
          symbol: holding.symbol,
        ).call()));
    print('${holding.symbol} ${cubits.holding.state.holding.symbol}');
    if (holding.symbol != cubits.holding.state.holding.symbol) {
      return;
    }
    update(
      mempool: transactions,
      isSubmitting: isSubmitting,
    );
    print('1 $isSubmitting');
  }

  void clearTransactions() {
    reachedEnd = false;
    update(mempool: [], transactions: []);
  }

  Future<void> slowlyClearTransactions() async {
    reachedEnd = false;
    update(clearing: true);
    await Future.delayed(fadeDuration,
        () => update(mempool: [], transactions: [], clearing: false));
  }

  /// update all the holding with the new rate
  List<TransactionDisplay> _newRateThese({
    Rate? rate,
    required List<TransactionDisplay> transactions,
  }) {
    if (transactions.isEmpty || rate == null || rate.rate <= 0) {
      return transactions;
    }
    return transactions
        .map((e) => e.copyWith(worth: e.fiat(rate.rate)))
        .toList();
  }

  /// sorts transactions from newest to oldest using the .when property
  List<TransactionDisplay> _sort(List<TransactionDisplay> transactions) =>
      transactions.sortedBy((e) => e.when).reversed.toList();

  void populate() => update(
          asset: Holding(
            name: 'Ravencoin',
            symbol: 'RVN',
            blockchain: Blockchain.ravencoinMain,
            sats: Sats(21),
            metadata: HoldingMetadata(
              divisibility: Divisibility(8),
              reissuable: false,
              supply: Sats.fromCoin(Coin(coin: 21000000000)),
            ),
          ),
          transactions: [
            for (final index in range(16))
              TransactionDisplay(
                  incoming: Random().nextInt(2) == 0,
                  when: DateTime.now(),
                  height: index,
                  sats: Sats(() {
                    final x = pow(index, index) as int;
                    if (x > 0 && x < 2100000000000000000) {
                      return x;
                    }
                    return index;
                  }()))
          ]);

  // todo pagenae list of holdings
  //Holding getNextBatch(List<Holding> batch) {}
}
