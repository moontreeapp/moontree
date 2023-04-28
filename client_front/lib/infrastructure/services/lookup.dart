// ignore_for_file: avoid_classes_with_only_static_members

import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/transaction.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class Current {
  static String get walletId => pros.settings.currentWalletId;

  static Wallet get wallet => pros.wallets.primaryIndex.getOne(walletId)!;

  static ChainNet get chainNet => pros.settings.chainNet;

  static Balance get balanceRVN =>
      services.balance.walletBalance(wallet, pros.securities.RVN);

  static Balance get balanceCurrency =>
      services.balance.walletBalance(wallet, pros.securities.currentCoin);

  static Set<Transaction> get transactions => wallet.transactions;

  static List<Balance> get holdings => wallet.balances;

  static List<String> get holdingNames =>
      components.cubits.holdingsView.state.holdingsViews
          .map((e) => e.symbol)
          .toList();
  //<String>[for (Balance balance in holdings) balance.security.symbol];

  static Iterable<String> get adminNames => holdings
      .where((Balance balance) => balance.security.asset?.isAdmin ?? false)
      .map((Balance balance) => balance.security.symbol);

  static Iterable<String> get qualifierNames => holdings
      .where((Balance balance) => balance.security.asset?.isQualifier ?? false)
      .map((Balance balance) => balance.security.symbol);

  static Chain get chain => pros.settings.chain;
  static Net get net => pros.settings.net;
  static Security get coin => pros.securities.currentCoin;

  static Security get holding =>
      components.cubits.transactionsView.state.security;
}
