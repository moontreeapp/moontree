part of 'joins.dart';

extension BalanceBelongsToWallet on Balance {
  Wallet? get wallet => res.wallets.primaryIndex.getOne(walletId);
}
