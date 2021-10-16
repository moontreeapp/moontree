import 'package:raven/security/cipher_base.dart';

import 'reservoirs/reservoirs.dart';
import 'records/records.dart';
import 'globals.dart' as globals;

// Joins on Account

extension AccountHasManyWallets on Account {
  List<Wallet> get wallets => globals.wallets.byAccount.getAll(accountId);
  List<LeaderWallet> get leaderWallets =>
      wallets.whereType<LeaderWallet>().toList();
  List<SingleWallet> get singleWallets =>
      wallets.whereType<SingleWallet>().toList();
}

extension AccountHasManyAddresses on Account {
  List<Address> get addresses =>
      wallets.map((wallet) => wallet.addresses).expand((i) => i).toList();
}

extension AccountHasManyTransactions on Account {
  List<Transaction> get transactions => addresses
      .map((address) => address.transactions)
      .expand((i) => i)
      .toList();
}

extension AccountHasManyVouts on Account {
  List<Vout> get vouts =>
      transactions.map((tx) => tx.vouts).expand((i) => i).toList();
}

extension AccountHasManyVins on Account {
  List<Vin> get vins =>
      transactions.map((tx) => tx.vins).expand((i) => i).toList();
}

extension AccountHasManyBalances on Account {
  List<Balance> get balances =>
      wallets.map((Wallet wallet) => wallet.balances).expand((i) => i).toList();
}

extension AccountHasManyUnspents on Account {
  List<Vout> get unspents =>
      VoutReservoir.whereUnspent(given: vouts, security: RVN).toList();
}

// Joins on Wallet

extension WalletBelongsToCipher on Wallet {
  CipherBase? get cipher => globals.cipherRegistry.ciphers[cipherUpdate];
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

extension WalletHasManyTransactions on Wallet {
  List<Transaction> get transactions => addresses
      .map((address) => address.transactions)
      .expand((i) => i)
      .toList();
}

extension WalletHasManyVouts on Wallet {
  List<Vout> get vouts =>
      transactions.map((tx) => tx.vouts).expand((i) => i).toList();
}

extension WalletHasManyVins on Wallet {
  List<Vin> get vins =>
      transactions.map((tx) => tx.vins).expand((i) => i).toList();
}

extension WalletHasManyUnspents on Wallet {
  List<Vout> get unspents =>
      VoutReservoir.whereUnspent(given: vouts, security: RVN).toList();
}

// Joins on Address

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension AddressBelongsToAccount on Address {
  Account? get account => wallet?.account;
}

extension AddressHasManyTransactions on Address {
  List<Transaction> get transactions =>
      globals.transactions.byScripthash.getAll(scripthash);
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts =>
      transactions.map((tx) => tx.vouts).expand((i) => i).toList();
}

extension AddressHasManyVins on Address {
  List<Vin> get vins =>
      transactions.map((tx) => tx.vins).expand((i) => i).toList();
}

// Joins on Balance

extension BalanceBelongsToWallet on Balance {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension BalanceBelongsToAccount on Balance {
  Account? get account => wallet?.account;
}

// Joins on Transaction

extension TransactionBelongsToAddress on Transaction {
  Address? get address => globals.addresses.primaryIndex.getOne(scripthash);
}

extension TransactionBelongsToWallet on Transaction {
  Wallet? get wallet => address?.wallet;
}

extension TransactionBelongsToAccount on Transaction {
  Account? get account => wallet?.account;
}

extension TransactionHasManyVins on Transaction {
  List<Vin> get vins => globals.vins.byTransaction.getAll(txId);
}

extension TransactionHasManyVouts on Transaction {
  List<Vout> get vouts => globals.vouts.byTransaction.getAll(txId);
}

// Joins on Vin (input to new transcation, points to 1 pre-existing vout)

extension VinBelongsToTransaction on Vin {
  Transaction? get transaction =>
      globals.transactions.primaryIndex.getOne(txId);
}

extension VinBelongsToVouts on Vin {
  Vout? get vouts =>
      globals.vouts.primaryIndex.getOne(Vout.getVoutId(voutTxId, voutPosition));
}

// Joins on Vout (adds to my value, consumed in whole)

extension VoutBelongsToTransaction on Vout {
  Transaction? get transaction =>
      globals.transactions.primaryIndex.getOne(txId);
}

extension VoutBelongsToVin on Vout {
  Vin? get vin =>
      globals.vins.primaryIndex.getOne(Vout.getVoutId(txId, position));
}
