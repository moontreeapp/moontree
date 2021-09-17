import 'reservoirs/reservoirs.dart';
import 'records/records.dart';
import 'globals.dart' as globals;

// Joins on Account

extension AccountHasManyWallets on Account {
  List<Wallet> get wallets => globals.wallets.byAccount.getAll(accountId);
}

extension AccountHasManyAddresses on Account {
  List<Address> get addresses =>
      wallets.map((wallet) => wallet.addresses).expand((i) => i).toList();
}

extension AccountHasManyHistories on Account {
  List<History> get histories =>
      addresses.map((address) => address.histories).expand((i) => i).toList();
}

extension AccountHasManyBalances on Account {
  List<Balance> get balances =>
      wallets.map((Wallet wallet) => wallet.balances).expand((i) => i).toList();
}

extension AccountHasManyUnspents on Account {
  List<History> get unspents =>
      HistoryReservoir.whereUnspent(given: histories, security: RVN).toList();
}

// Joins on Wallet

extension WalletBelongsToCipher on Wallet {
  // TODO: Can we make a join on wallet through the `ciphers` registry here?
  // Cipher? get cipher =>
}

extension WalletBelongsToAccount on Wallet {
  Account? get account => globals.accounts.primaryIndex.getOne(accountId);
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses => globals.addresses.byWallet.getAll(walletId);
}

extension WalletHasManyBalances on Wallet {
  List<Balance> get balances => globals.balances.byWallet.getAll(walletId);
}

extension WalletHasManyHistories on Wallet {
  List<History> get histories =>
      addresses.map((address) => address.histories).expand((i) => i).toList();
}

extension WalletHasManyUnspents on Wallet {
  List<History> get unspents =>
      HistoryReservoir.whereUnspent(given: histories, security: RVN).toList();
}

// Joins on Address

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension AddressBelongsToAccount on Address {
  Account? get account => wallet?.account;
}

extension AddressHasManyHistories on Address {
  List<History> get histories =>
      globals.histories.byScripthash.getAll(scripthash);
}

// Joins on Balance

extension BalanceBelongsToWallet on Balance {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension BalanceBelongsToAccount on Balance {
  Account? get account => wallet?.account;
}

// Joins on History

extension HistoryBelongsToAddress on History {
  Address? get address => globals.addresses.primaryIndex.getOne(scripthash);
}

extension HistoryBelongsToWallet on History {
  Wallet? get wallet => address?.wallet;
}

extension HistoryBelongsToAccount on History {
  Account? get account => wallet?.account;
}
