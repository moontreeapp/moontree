import 'dart:math';

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
import 'package:magic/presentation/utils/range.dart';
import 'package:magic/services/calls/transactions.dart';
import 'package:magic/services/services.dart';

part 'state.dart';

class TransactionsCubit extends UpdatableCubit<TransactionsState> {
  TransactionsCubit() : super(const TransactionsState());
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
    List<TransactionDisplay>? transactions,
    Widget? child,
    bool? isSubmitting,
  }) {
    emit(TransactionsState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      transactions: transactions ?? state.transactions,
      child: child ?? state.child,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }

  Future<void> populateTransactions([Holding? holding]) async {
    // remember to order by currency first, amount second, alphabetical third
    update(isSubmitting: true);
    if (holding != null && holding != state.asset) {
      update(transactions: []);
    }
    final transactions = _newRateThese(
        rate: rates.rvnUsdRate, // rates by blockchain and symbol...security?
        transactions: await TransactionHistoryCall(
          mnemonicWallets: cubits.keys.master.mnemonicWallets,
          keypairWallets: cubits.keys.master.keypairWallets,
          blockchain: state.asset.blockchain ?? Blockchain.ravencoinMain,
          height: state.transactions.length,
          symbol: state.asset.symbol,
        ).call());
    update(
        transactions: state.transactions + transactions, isSubmitting: false);
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

  void populate() => update(
          asset: Holding(
            name: 'Ravencoin',
            symbol: 'RVN',
            root: 'RVN',
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
