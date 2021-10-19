import 'package:raven/security/cipher_base.dart';
import 'package:raven/utils/transform.dart';

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

//extension AccountHasManyTransactions on Account {
//  List<Transaction> get transactions => addresses
//      .map((address) => address.transactions)
//      .expand((i) => i)
//      .toList();
//}

extension AccountHasManyVouts on Account {
  Iterable<Vout> get vouts =>
      globals.vouts.data.where((vout) => vout.account!.accountId == accountId);
}

extension AccountHasManyVins on Account {
  Iterable<Vin> get vins =>
      globals.vins.data.where((vin) => vin.account!.accountId == accountId);
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

//extension WalletHasManyTransactions on Wallet {
//  List<Transaction> get transactions => addresses
//      .map((address) => address.transactions)
//      .expand((i) => i)
//      .toList();
//}
//
extension WalletHasManyVouts on Wallet {
  Iterable<Vout> get vouts =>
      globals.vouts.data.where((vout) => vout.wallet!.walletId == walletId);
}

extension WalletHasManyVins on Wallet {
  Iterable<Vin> get vins =>
      globals.vins.data.where((vin) => vin.wallet!.walletId == walletId);
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

//extension AddressHasManyTransactions on Address {
//  List<Transaction> get transactions =>
//      vouts.map((vout) => vout.transaction).expand((i) => i).toList() +
//      vins.map((vin) => vin.transaction).expand((i) => i).toList();
//}

// Joins on Balance

extension BalanceBelongsToWallet on Balance {
  Wallet? get wallet => globals.wallets.primaryIndex.getOne(walletId);
}

extension BalanceBelongsToAccount on Balance {
  Account? get account => wallet?.account;
}

// Joins on Transaction

//extension TransactionBelongsToAddress on Transaction {
//  Address? get address => globals.addresses.primaryIndex.getOne(scripthash);
//}
//
//extension TransactionBelongsToWallet on Transaction {
//  Wallet? get wallet => address?.wallet;
//}
//
//extension TransactionBelongsToAccount on Transaction {
//  Account? get account => wallet?.account;
//}

extension TransactionHasManyVins on Transaction {
  List<Vin> get vins => globals.vins.byTransaction.getAll(txId);
}

extension TransactionHasManyVouts on Transaction {
  List<Vout> get vouts => globals.vouts.byTransaction.getAll(txId);
}

//extension TransactionBelongsToAddress on Transaction {
//  List<Address>? get addresses => vins .address + vouts.address;
//}

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
  Address? get address => vout?.address!;
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

extension VoutMayHaveOneVin on Vout {
  Vin? get vin =>
      globals.vins.primaryIndex.getOne(Vout.getVoutId(txId, position));
}

extension VoutHasOneSecurity on Vout {
  Security? get security => globals.securities.primaryIndex.getOne(securityId);
}

extension VoutBelongsToAddress on Vout {
  Address? get address => globals.addresses.byAddress.getOne(toAddress);
}

extension VoutBelongsToWallet on Vout {
  Wallet? get wallet => address?.wallet;
}

extension VoutBelongsToAccount on Vout {
  Account? get account => wallet?.account;
}
