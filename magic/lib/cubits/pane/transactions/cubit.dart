import 'dart:math';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/money/rate.dart';
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

  late bool reachedEnd = false;
  final Map<Asset, List<TransactionDisplay>> transactionsByAsset = {};

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
    Asset? asset,
    List<TransactionDisplay>? mempool,
    List<TransactionDisplay>? transactions,
    Widget? child,
    bool? clearing,
    bool? isSubmitting,
  }) {
    if (transactions != null && asset != null) {
      transactions = syncTransactions(transactions, asset);
    }

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
    if (transactionsByAsset.containsKey(holding.asset)) {
      update(isSubmitting: true);
      update(
          asset: holding.asset,
          transactions: transactionsByAsset[holding.asset]);
      await populateTransactions(holding: holding, fromHeight: fromHeight);
      await populateMempoolTransactions(holding: holding);
      update(isSubmitting: false);
    } else {
      await populateTransactions(holding: holding, fromHeight: fromHeight);
      update(isSubmitting: true);
      await populateTransactions(holding: holding, fromHeight: fromHeight);
      await populateMempoolTransactions(holding: holding);
      if (holding.symbol != cubits.holding.state.holding.symbol) {
        return;
      }
      update(isSubmitting: false);
    }
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
    final replace = holding != cubits.holding.state.holding;
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
      asset: holding.asset,
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
    if (holding.symbol != cubits.holding.state.holding.symbol) {
      return;
    }
    update(
      mempool: transactions,
      isSubmitting: isSubmitting,
    );
  }

  void clearTransactions() {
    reachedEnd = false;
    update(asset: const Asset.empty(), mempool: [], transactions: []);
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
          asset: const Asset(
            name: 'Ravencoin',
            symbol: 'RVN',
            blockchain: Blockchain.ravencoinMain,
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

  List<TransactionDisplay> syncTransactions(
    List<TransactionDisplay> newTransactions,
    Asset holding,
  ) {
    if (!transactionsByAsset.containsKey(holding)) {
      transactionsByAsset[holding] = [];
    }
    List<TransactionDisplay> cachedTransactions = transactionsByAsset[holding]!;
    for (var newTransaction in newTransactions) {
      if (!cachedTransactions
          .any((cached) => cached.height == newTransaction.height)) {
        cachedTransactions.add(newTransaction);
      }
    }
    cachedTransactions.sort((a, b) => b.height.compareTo(a.height));
    transactionsByAsset[holding] = cachedTransactions;
    return cachedTransactions;
  }
}
