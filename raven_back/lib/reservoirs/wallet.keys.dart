part of 'wallet.dart';

/// primary key

class _IdKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.walletId;
}

extension ByIdMethodsForWallet on Index<_IdKey, Wallet> {
  Wallet? getOne(String walletId) {
    getByKeyStr(walletId).firstOrNull;
  }

  LeaderWallet? getOneLeaderWallet(String walletId) {
    var wallet = getByKeyStr(walletId).firstOrNull;
    if (wallet != null && wallet is LeaderWallet) {
      return wallet;
    }
    return null;
  }

  SingleWallet? getOneSingleWallet(String walletId) {
    var wallet = getByKeyStr(walletId).firstOrNull;
    if (wallet != null && wallet is SingleWallet) {
      return wallet;
    }
    return null;
  }
}

/// byAccount

class _AccountKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.accountId;
}

extension ByAccountMethodsForWallet on Index<_AccountKey, Wallet> {
  List<Wallet> getAll(String accountId) => getByKeyStr(accountId);
  Wallet? getOne(String accountId) => getByKeyStr(accountId).firstOrNull;
}
