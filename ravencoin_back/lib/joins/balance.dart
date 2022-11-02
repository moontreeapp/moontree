part of 'joins.dart';

extension BalanceBelongsToWallet on Balance {
  Wallet? get wallet => pros.wallets.primaryIndex.getOne(walletId);
}
