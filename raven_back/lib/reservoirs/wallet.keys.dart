part of 'wallet.dart';

/// primary key

class _IdKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.walletId;
}

extension ByIdMethodsForWallet on Index<_IdKey, Wallet> {
  Wallet? getOne(String walletId) => getByKeyStr(walletId).firstOrNull;
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

/// byAccount

class _WalletTypeKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.walletTypeToString;
}

extension ByWalletTypeMethodsForWallet on Index<_WalletTypeKey, Wallet> {
  List<Wallet> getAllByString(String walletType) => getByKeyStr(walletType);
  List<Wallet> getAll(WalletType walletType) =>
      getByKeyStr(walletType.enumString);
}
