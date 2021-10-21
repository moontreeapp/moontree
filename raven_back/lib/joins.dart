import 'package:raven/security/cipher_base.dart';
import 'package:raven/utils/extensions.dart';

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

extension AccountHasManyBalances on Account {
  List<Balance> get balances =>
      wallets.map((Wallet wallet) => wallet.balances).expand((i) => i).toList();
}

extension AccountHasManyVouts on Account {
  Iterable<Vout> get vouts =>
      globals.vouts.data.where((vout) => vout.account?.accountId == accountId);
}

extension AccountHasManyVins on Account {
  Iterable<Vin> get vins =>
      globals.vins.data.where((vin) => vin.account?.accountId == accountId);
}

extension AccountHasManyTransactions on Account {
  Set<Transaction> get transactions =>
      (this.vouts.map((vout) => vout.transaction!).toList() +
              this.vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
}

// Joins on Wallet

extension WalletBelongsToCipher on Wallet {
  //CipherBase? get cipher => globals.cipherRegistry.ciphers[cipherUpdate];
  CipherBase? get cipher =>
      globals.ciphers.primaryIndex.getOne(cipherUpdate)?.cipher;
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

extension WalletHasManyVouts on Wallet {
  Iterable<Vout> get vouts =>
      globals.vouts.data.where((vout) => vout.wallet?.walletId == walletId);
}

extension WalletHasManyVins on Wallet {
  Iterable<Vin> get vins =>
      globals.vins.data.where((vin) => vin.wallet?.walletId == walletId);
}

extension WalletHasManyTransactions on Wallet {
  Set<Transaction> get transactions =>
      (this.vouts.map((vout) => vout.transaction!).toList() +
              this.vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
}

// Joins on Address

extension AddressBelongsToWallet on Address {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension AddressBelongsToAccount on Address {
  Account? get account => wallet?.account;
}

extension AddressHasManyVouts on Address {
  List<Vout> get vouts => globals.vouts.byScripthash.getAll(addressId);
}

extension AddressHasManyVins on Address {
  List<Vin> get vins => globals.vins.byScripthash.getAll(addressId);
}

extension AddressHasManyTransactions on Address {
  Set<Transaction> get transactions =>
      (this.vouts.map((vout) => vout.transaction!).toList() +
              this.vins.map((vin) => vin.transaction!).toList())
          .toSet()
        ..remove(null);
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
  Set<Address?>? get addresses =>
      (this.vouts.map((vout) => vout.address).toList() +
              this.vins.map((vin) => vin.address).toList())
          .toSet()
        ..remove(null);
}

extension TransactionBelongsToWallet on Transaction {
  Set<Wallet?>? get wallets => (this.vouts.map((vout) => vout.wallet).toList() +
          this.vins.map((vin) => vin.wallet).toList())
      .toSet()
    ..remove(null);
}

extension TransactionBelongsToAccount on Transaction {
  Set<Account?>? get accounts =>
      (this.vouts.map((vout) => vout.account).toList() +
              this.vins.map((vin) => vin.account).toList())
          .toSet()
        ..remove(null);
}

extension TransactionHasManyVins on Transaction {
  List<Vin> get vins => globals.vins.byTransaction.getAll(txId);
}

extension TransactionHasManyVouts on Transaction {
  List<Vout> get vouts => globals.vouts.byTransaction.getAll(txId);
}

extension TransactionHasManyMemos on Transaction {
  List<String> get memos => globals.vouts.byTransaction
      .getAll(txId)
      .map((vout) => vout.memo)
      .toList();
}

extension TransactionHasOneValue on Transaction {
  int get value => globals.vouts.byTransaction
      .getAll(txId)
      .map((vout) => vout.value)
      .toList()
      .sumInt();
}

// Joins on Vin (input to new transcation, points to 1 pre-existing vout)

extension VinBelongsToTransaction on Vin {
  Transaction? get transaction =>
      globals.transactions.primaryIndex.getOne(txId);
}

extension VinHasOneVout on Vin {
  Vout? get vout =>
      globals.vouts.primaryIndex.getOne(Vout.getVoutId(voutTxId, voutPosition));
}

extension VinHasOneSecurity on Vin {
  Security? get security => vout?.security;
}

extension VinHasOneValue on Vin {
  int? get value => vout?.value;
}

extension VinBelongsToAddress on Vin {
  Address? get address => vout?.address;
}

extension VinBelongsToWallet on Vin {
  Wallet? get wallet => address?.wallet;
}

extension VinBelongsToAccount on Vin {
  Account? get account => wallet?.account;
}

// Joins on Vout (adds to my value, consumed in whole)

extension VoutBelongsToTransaction on Vout {
  Transaction? get transaction =>
      globals.transactions.primaryIndex.getOne(txId);
}

extension VoutBelongsToVin on Vout {
  Vin? get vin => globals.vins.byVoutId.getOne(Vout.getVoutId(txId, position));
  // no vin - this is a unspent output
}

extension VoutHasOneSecurity on Vout {
  Security? get security => globals.securities.primaryIndex.getOne(securityId);
}

extension VoutBelongsToAddress on Vout {
  Address? get address => globals.addresses.byAddress.getOne(toAddress);
  // no address - we don't own this vout
}

extension VoutBelongsToWallet on Vout {
  Wallet? get wallet => address?.wallet;
  // no wallet - we don't own this vout
}

extension VoutBelongsToAccount on Vout {
  Account? get account => wallet?.account;
  // no account - we don't own this vout
}
