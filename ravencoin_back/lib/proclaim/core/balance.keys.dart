part of 'balance.dart';

// primary key

class _WalletSecurityKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.id;
}

extension ByWalletSecurityMethodsForBalance
    on Index<_WalletSecurityKey, Balance> {
  Balance? getOne(String walletId, Security security) =>
      getByKeyStr(Balance.key(walletId, security)).firstOrNull;
}

// byWallet

class _WalletKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.walletId;
}

extension ByWalletMethodsForBalance on Index<_WalletKey, Balance> {
  List<Balance> getAll(String walletId) => getByKeyStr(walletId);
}

// bySecurity

class _SecurityKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.security.id;
}

extension BySecurityMethodsForBalance on Index<_SecurityKey, Balance> {
  List<Balance> getAll(Security security) => getByKeyStr(security.id);
}

// primary keyChain

class _WalletSecurityChainKey extends Key<Balance> {
  @override
  String getKey(Balance balance) => balance.idChain;
}

extension ByWalletSecurityChainMethodsForBalance
    on Index<_WalletSecurityChainKey, Balance> {
  Balance? getOne(String walletId, Security security, Chain chain, Net net) =>
      getByKeyStr(Balance.balanceChainKey(walletId, security, chain, net))
          .firstOrNull;
}

// byWalletChain

class _WalletChainKey extends Key<Balance> {
  @override
  String getKey(Balance balance) =>
      Balance.walletChainKey(balance.walletId, balance.chain, balance.net);
}

extension ByWalletChainMethodsForBalance on Index<_WalletChainKey, Balance> {
  List<Balance> getAll(String walletId, Chain chain, Net net) =>
      getByKeyStr(Balance.walletChainKey(walletId, chain, net));
}

// bySecurityChain

class _SecurityChainKey extends Key<Balance> {
  @override
  String getKey(Balance balance) =>
      Balance.securityChainKey(balance.security, balance.chain, balance.net);
}

extension BySecurityChainMethodsForBalance
    on Index<_SecurityChainKey, Balance> {
  List<Balance> getAll(Security security, Chain chain, Net net) =>
      getByKeyStr(Balance.securityChainKey(security, chain, net));
}
