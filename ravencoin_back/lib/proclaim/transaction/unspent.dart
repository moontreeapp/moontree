import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'unspent.keys.dart';

class UnspentProclaim extends Proclaim<_IdKey, Unspent> {
  late IndexMultiple<_VoutIdKey, Unspent> byVoutId;
  //late IndexMultiple<_SecurityKey, Unspent> bySecurity;
  //late IndexMultiple<_SecurityTypeKey, Unspent> bySecurityType;
  late IndexMultiple<_AddressKey, Unspent> byAddress;
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
    byVoutId = addIndexMultiple('transaction', _VoutIdKey());
    //bySecurity = addIndexMultiple('security', _SecurityKey());
    //bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
    byAddress = addIndexMultiple('address', _AddressKey());
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byWalletSymbol = addIndexMultiple('walletSymbol', _WalletSymbolKey());
    //byWalletConfirmation =
    //    addIndexMultiple('walletConfirmation', _WalletConfirmationKey());
    //byWalletSymbolConfirmation = addIndexMultiple(
    //    'walletSymbolConfirmation', _WalletSymbolConfirmationKey());
    bySymbolChain = addIndexMultiple('symbolChain', _SymbolChainKey());
    byWalletChain = addIndexMultiple('walletChain', _WalletChainKey());
    byWalletChainSymbol =
        addIndexMultiple('walletChainSymbol', _WalletChainSymbolKey());
    //byWalletChainConfirmation = addIndexMultiple(
    //    'walletChainConfirmation', _WalletChainConfirmationKey());
    byWalletChainSymbolConfirmation = addIndexMultiple(
        'walletChainSymbolConfirmation', _WalletChainSymbolConfirmationKey());
  }

  // on startup it's blank
  static Map<String, Unspent> get defaults => {};

  Iterable<Unspent> byScripthashes(Set<String> scripthashes) =>
      pros.unspents.records.where((e) => scripthashes.contains(e.scripthash));
  Future<void> clearByScripthashes(Set<String> scripthashes) async =>
      await pros.unspents.removeAll(byScripthashes(scripthashes));

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
    symbol = symbol ?? 'RVN';
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
