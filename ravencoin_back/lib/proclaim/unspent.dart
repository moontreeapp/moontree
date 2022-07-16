import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'unspent.keys.dart';

class UnspentProclaim extends Proclaim<_UnspentKey, Unspent> {
  late IndexMultiple<_TransactionKey, Unspent> byTransaction;
  late IndexMultiple<_TransactionPositionKey, Unspent> byTransactionPosition;
  late IndexMultiple<_SecurityKey, Unspent> bySecurity;
  late IndexMultiple<_SecurityTypeKey, Unspent> bySecurityType;
  late IndexMultiple<_AddressKey, Unspent> byAddress;
  late IndexMultiple<_SymbolKey, Unspent> bySymbol;
  late IndexMultiple<_WalletKey, Unspent> byWallet;
  late IndexMultiple<_WalletSymbolKey, Unspent> byWalletSymbol;
  late IndexMultiple<_WalletConfirmationKey, Unspent> byWalletConfirmation;
  late IndexMultiple<_WalletSymbolConfirmationKey, Unspent>
      byWalletSymbolConfirmation;

  UnspentProclaim() : super(_UnspentKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    byTransactionPosition =
        addIndexMultiple('transaction-position', _TransactionPositionKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
    bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
    byAddress = addIndexMultiple('address', _AddressKey());
    bySymbol = addIndexMultiple('symbol', _SymbolKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byWalletSymbol = addIndexMultiple('walletSymbol', _WalletSymbolKey());
    byWalletConfirmation =
        addIndexMultiple('walletConfirmation', _WalletConfirmationKey());
    byWalletSymbolConfirmation = addIndexMultiple(
        'walletSymbolConfirmation', _WalletSymbolConfirmationKey());
  }

  // on startup it's blank
  static Map<String, Unspent> get defaults => {};

  Iterable<Unspent> byScripthashes(Set<String> scripthashes) =>
      pros.unspents.data.where((e) => scripthashes.contains(e.scripthash));
  Future<void> clearByScripthashes(Set<String> scripthashes) async =>
      await pros.unspents.removeAll(byScripthashes(scripthashes));

  int totalConfirmed(String walletId, [String symbol = 'RVN']) =>
      byWalletSymbolConfirmation
          .getAll(walletId, symbol, true)
          .map((e) => e.value)
          .sumInt();

  int totalUnconfirmed(String walletId, [String symbol = 'RVN']) =>
      byWalletSymbolConfirmation
          .getAll(walletId, symbol, false)
          .map((e) => e.value)
          .sumInt();

  void assertSufficientFunds(
    String walletId,
    int amount, {
    String? symbol,
    bool allowUnconfirmed = true,
  }) {
    symbol = symbol ?? 'RVN';
    if (totalConfirmed(walletId, symbol) +
            (allowUnconfirmed ? totalUnconfirmed(walletId, symbol) : 0) <
        amount) {
      throw InsufficientFunds();
    }
  }

  Set<String> get getSymbols => pros.unspents.data.map((e) => e.symbol).toSet();

  Set<String> getSymbolsByWallet(String walletId) =>
      byWallet.getAll(walletId).map((e) => e.symbol).toSet();
}
