part of 'joins.dart';

// Joins on Account

extension AccountHasManyWallets on Account {
  List<Wallet> get wallets => globals.res.wallets.byAccount.getAll(accountId);
  List<LeaderWallet> get leaderWallets =>
      wallets.whereType<LeaderWallet>().toList();
  List<SingleWallet> get singleWallets =>
      wallets.whereType<SingleWallet>().toList();
}

extension AccountHasManyAddresses on Account {
  List<Address> get addresses =>
      wallets.map((wallet) => wallet.addresses).expand((i) => i).toList();
}

extension AccountHasManyBalances on Account {
  List<Balance> get balances =>
      wallets.map((Wallet wallet) => wallet.balances).expand((i) => i).toList();
}

extension AccountHasManyVouts on Account {
  Iterable<Vout> get vouts => globals.res.vouts.data
      .where((vout) => vout.account?.accountId == accountId);
}

extension AccountHasManyVins on Account {
  Iterable<Vin> get vins =>
      globals.res.vins.data.where((vin) => vin.account?.accountId == accountId);
}

extension AccountHasManyTransactions on Account {
  Set<Transaction> get transactions =>
      (vouts.map((vout) => vout.transaction!).toList() +
              vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
}
