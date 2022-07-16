part of 'wallet.dart';

/// primary key

class _IdKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.id;
}

extension ByIdMethodsForWallet on Index<_IdKey, Wallet> {
  Wallet? getOne(String walletId) => getByKeyStr(walletId).firstOrNull;
}

/// byWalletType

class _WalletTypeKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.walletTypeToString;
}

extension ByWalletTypeMethodsForWallet on Index<_WalletTypeKey, Wallet> {
  List<Wallet> getAllByString(String walletType) => getByKeyStr(walletType);
  List<Wallet> getAll(WalletType walletType) =>
      getByKeyStr(walletType.enumString);
}

/// byWalletType

class _NameKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.name;
}

extension ByNameMethodsForWallet on Index<_NameKey, Wallet> {
  Wallet? getOne(String name) => getByKeyStr(name).firstOrNull;
}
