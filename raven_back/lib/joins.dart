import 'reservoirs/reservoirs.dart';
import 'records/records.dart';
import 'globals.dart' as globals;

// Joins on Account

extension AccountHasManyWallets on Account {
  List<Wallet> get wallets => globals.wallets.byAccount.getAll(accountId);
}

extension AccountHasManyBalances on Account {
  List<Balance> get balances => globals.balances.byAccount.getAll(accountId);
}

// Joins on Wallet

extension WalletBelongsToAccount on Wallet {
  Account? get account => globals.accounts.primaryIndex.getOne(accountId);
}

extension WalletHasManyAddresses on Wallet {
  List<Address> get addresses => globals.addresses.byWallet.getAll(walletId);
}

// Joins on Address

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension AddressBelongsToAccount on Address {
  Account? get account {
    var accountId = globals.wallets.primaryIndex.getOne(walletId)?.accountId;
    if (accountId == null) return null;
    return globals.accounts.primaryIndex.getOne(accountId);
  }
}

// Joins on Balance

extension BalanceBelongsToAccount on Wallet {
  Account? get account => globals.accounts.primaryIndex.getOne(accountId);
}

// Joins on History

extension HistoryBelongsToAddress on History {
  Address? get address => globals.addresses.primaryIndex.getOne(scripthash);
}
