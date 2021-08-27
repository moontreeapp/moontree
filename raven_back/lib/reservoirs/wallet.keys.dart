part of 'wallet.dart';

// primary key

class _IdKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.id;
}

extension ByIdMethodsForWallet on Index<_IdKey, Wallet> {
  Wallet? getOne(String accountId) {
    var wallets = getByKeyStr(accountId);
    return wallets.isEmpty ? null : wallets.first;
  }
}

// byAccount

class _AccountKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.accountId;
}

extension ByAccountMethodsForWallet on Index<_AccountKey, Wallet> {
  List<Wallet> getAll(String accountId) => getByKeyStr(accountId);
}
