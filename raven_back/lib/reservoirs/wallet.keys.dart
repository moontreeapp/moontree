part of 'wallet.dart';

/// primary key

class _IdKey extends Key<Wallet> {
  @override
  String getKey(Wallet wallet) => wallet.walletId;
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
