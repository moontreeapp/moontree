part of 'unspent.dart';

// primary key

class _UnspentKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.id;
}

extension ByIdMethodsForUnspent on Index<_UnspentKey, Unspent> {
  Unspent? getOne(String hash) => getByKeyStr(hash).firstOrNull;
}

// byTransaction

class _TransactionKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.transactionId;
}

extension ByTransactionMethodsForUnspent on Index<_TransactionKey, Unspent> {
  List<Unspent> getAll(String transactionId) => getByKeyStr(transactionId);
}

// byTransactionPosition same as primary

class _TransactionPositionKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.id;
}

extension ByTransactionPositionMethodsForUnspent
    on Index<_TransactionPositionKey, Unspent> {
  Unspent? getOne(String transactionId, int position) =>
      getByKeyStr(Unspent.getUnspentId(transactionId, position)).firstOrNull;
}

// bySecurity

class _SecurityKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.security.id;
}

extension BySecurityMethodsForUnspent on Index<_SecurityKey, Unspent> {
  List<Unspent> getAll(Security security) => getByKeyStr(security.id);
}

// bySecurityType

class _SecurityTypeKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.security.securityType.name;
}

extension BySecurityTypeMethodsForUnspent on Index<_SecurityTypeKey, Unspent> {
  List<Unspent> getAll(SecurityType securityType) =>
      getByKeyStr(securityType.name);
}

// byAddress - (toAddress)

class _AddressKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.addressId;
}

extension ByAddressMethodsForUnspent on Index<_AddressKey, Unspent> {
  List<Unspent> getAll(String address) => getByKeyStr(address);
}

// bySymbol

class _SymbolKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.symbol;
}

extension BySymbolMethodsForUnspent on Index<_SymbolKey, Unspent> {
  List<Unspent> getAll(String symbol) => getByKeyStr(symbol);
}

// bySymbolChain

class _SymbolChainKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) =>
      Unspent.getChainSymbolId(unspent.chain, unspent.symbol);
}

extension BySymbolChainMethodsForUnspent on Index<_SymbolChainKey, Unspent> {
  List<Unspent> getAll(String symbol, Chain chain) =>
      getByKeyStr(Unspent.getChainSymbolId(chain, symbol));
}

// byWallet

class _WalletKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.walletId;
}

extension ByWalletMethodsForUnspent on Index<_WalletKey, Unspent> {
  List<Unspent> getAll(String walletId) => getByKeyStr(walletId);
}

// byWalletSymbol

class _WalletSymbolKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.walletSymbolId;
}

extension ByWalletSymbolMethodsForUnspent on Index<_WalletSymbolKey, Unspent> {
  List<Unspent> getAll(String walletId, String? symbol) =>
      getByKeyStr(Unspent.getWalletSymbolId(walletId, symbol ?? 'RVN'));
}

// byWalletChain

class _WalletChainKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) =>
      Unspent.getWalletChainId(unspent.walletId, unspent.chain);
}

extension ByWalletChainMethodsForUnspent on Index<_WalletChainKey, Unspent> {
  List<Unspent> getAll(String walletId, Chain chain) =>
      getByKeyStr(Unspent.getWalletChainId(walletId, chain));
}

// byWalletChainSymbol

class _WalletChainSymbolKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => Unspent.getWalletChainSymbolId(
      unspent.walletId, unspent.chain, unspent.symbol);
}

extension ByWalletChainSymbolMethodsForUnspent
    on Index<_WalletChainSymbolKey, Unspent> {
  List<Unspent> getAll(String walletId, Chain chain, String? symbol) =>
      getByKeyStr(
          Unspent.getWalletChainSymbolId(walletId, chain, symbol ?? 'RVN'));
}

// byWalletConfirmation

class _WalletConfirmationKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.walletConfirmationId;
}

extension ByWalletConfirmationMethodsForUnspent
    on Index<_WalletConfirmationKey, Unspent> {
  List<Unspent> getAll(String walletId, bool confirmed) =>
      getByKeyStr(Unspent.getWalletConfirmationId(walletId, confirmed));
}

// byWalletSymbolConfirmation

class _WalletSymbolConfirmationKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => unspent.walletSymbolConfirmationId;
}

extension ByWalletSymbolConfirmationMethodsForUnspent
    on Index<_WalletSymbolConfirmationKey, Unspent> {
  List<Unspent> getAll(String walletId, String? symbol, bool confirmed) =>
      getByKeyStr(Unspent.getWalletSymbolConfirmationId(
          walletId, symbol ?? 'RVN', confirmed));
}

// byWalletConfirmation

class _WalletChainConfirmationKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => Unspent.getWalletChainConfirmationId(
      unspent.walletId, unspent.chain, unspent.isConfirmed);
}

extension ByWalletChainConfirmationMethodsForUnspent
    on Index<_WalletChainConfirmationKey, Unspent> {
  List<Unspent> getAll(String walletId, Chain chain, bool confirmed) =>
      getByKeyStr(
          Unspent.getWalletChainConfirmationId(walletId, chain, confirmed));
}

// byWalletChainSymbolConfirmation

class _WalletChainSymbolConfirmationKey extends Key<Unspent> {
  @override
  String getKey(Unspent unspent) => Unspent.getWalletChainSymbolConfirmationId(
      unspent.walletId, unspent.chain, unspent.symbol, unspent.isConfirmed);
}

extension ByWalletChainSymbolConfirmationMethodsForUnspent
    on Index<_WalletChainSymbolConfirmationKey, Unspent> {
  List<Unspent> getAll(
          String walletId, Chain chain, String? symbol, bool confirmed) =>
      getByKeyStr(Unspent.getWalletChainSymbolConfirmationId(
          walletId, chain, symbol ?? 'RVN', confirmed));
}
