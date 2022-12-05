import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'unspent.keys.dart';

class UnspentProclaim extends Proclaim<_IdKey, Unspent> {
  late IndexMultiple<_VoutIdKey, Unspent> byVoutId;
  //late IndexMultiple<_SecurityKey, Unspent> bySecurity;
  late IndexMultiple<_AddressKey, Unspent> byAddress;
  late IndexMultiple<_ChainNetKey, Unspent> byChainNet;
  late IndexMultiple<_SymbolKey, Unspent> bySymbol;
  late IndexMultiple<_WalletKey, Unspent> byWallet;
  late IndexMultiple<_WalletSymbolKey, Unspent> byWalletSymbol;
  //late IndexMultiple<_WalletConfirmationKey, Unspent> byWalletConfirmation;
  //late IndexMultiple<_WalletSymbolConfirmationKey, Unspent>
  //    byWalletSymbolConfirmation;
  late IndexMultiple<_SymbolChainKey, Unspent> bySymbolChain;
  late IndexMultiple<_WalletChainKey, Unspent> byWalletChain;
  late IndexMultiple<_WalletChainSymbolKey, Unspent> byWalletChainSymbol;
  //late IndexMultiple<_WalletChainConfirmationKey, Unspent>
  //    byWalletChainConfirmation;
  late IndexMultiple<_WalletChainSymbolConfirmationKey, Unspent>
      byWalletChainSymbolConfirmation;

  UnspentProclaim() : super(_IdKey()) {
    byVoutId = addIndexMultiple('byVoutId', _VoutIdKey());
    byAddress = addIndexMultiple('byAddress', _AddressKey());
    byChainNet = addIndexMultiple('byChainNet', _ChainNetKey());
    bySymbol = addIndexMultiple('bySymbol', _SymbolKey());
    byWallet = addIndexMultiple('byWallet', _WalletKey());
    byWalletSymbol = addIndexMultiple('byWalletSymbol', _WalletSymbolKey());
    bySymbolChain = addIndexMultiple('bySymbolChain', _SymbolChainKey());
    byWalletChain = addIndexMultiple('byWalletChain', _WalletChainKey());
    byWalletChainSymbol =
        addIndexMultiple('byWalletChainSymbol', _WalletChainSymbolKey());
    byWalletChainSymbolConfirmation = addIndexMultiple(
        'byWalletChainSymbolConfirmation', _WalletChainSymbolConfirmationKey());
  }

  // on startup it's blank
  static Map<String, Unspent> get defaults => {};

  Iterable<Unspent> byScripthashes(
    Set<String> scripthashes, [
    Chain? chain,
    Net? net,
  ]) =>
      pros.unspents.byChainNet
          .getAll(chain ?? pros.settings.chain, net ?? pros.settings.net)
          .where((e) => scripthashes.contains(e.scripthash));
  Future<void> clearByScripthashes(
    Set<String> scripthashes, [
    Chain? chain,
    Net? net,
  ]) async =>
      await pros.unspents.removeAll(byScripthashes(scripthashes, chain, net));

  int totalConfirmed(
    String walletId, {
    required String? symbol,
    required Chain chain,
    required Net net,
  }) =>
      byWalletChainSymbolConfirmation
          .getAll(walletId, chain, net, symbol ?? 'RVN', true)
          .map((e) => e.value)
          .sumInt();

  int totalUnconfirmed(
    String walletId, {
    required String? symbol,
    required Chain chain,
    required Net net,
  }) =>
      byWalletChainSymbolConfirmation
          .getAll(walletId, chain, net, symbol ?? 'RVN', false)
          .map((e) => e.value)
          .sumInt();

  void assertSufficientFunds(
    String walletId,
    int amount, {
    required Chain chain,
    required Net net,
    String? symbol,
    bool allowUnconfirmed = true,
  }) {
    symbol = symbol ?? chain.symbol;
    if (totalConfirmed(walletId, symbol: symbol, chain: chain, net: net) +
            (allowUnconfirmed
                ? totalUnconfirmed(walletId,
                    symbol: symbol, chain: chain, net: net)
                : 0) <
        amount) {
      throw InsufficientFunds();
    }
  }

  Set<String> get getSymbols =>
      pros.unspents.records.map((e) => e.symbol).toSet();

  Set<String> getSymbolsByWallet(String walletId) =>
      byWallet.getAll(walletId).map((e) => e.symbol).toSet();
}
