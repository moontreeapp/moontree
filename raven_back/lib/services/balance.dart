/// balances are by wallet
/// if you want the balance of a subwallet (address) then get it from Histories.

// ignore_for_file: omit_local_variable_types
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:raven_back/services/wallet_security_pair.dart';
import 'package:raven_back/raven_back.dart';

class BalanceService {
  /// Listener Logic //////////////////////////////////////////////////////////

  Future recalculateAllBalances() async {
    // wont work when it needs to until we save asset data when we save unspents
    /// erase first see 517
    //await res.balances.removeAll(res.balances.data);
    Set<Balance> balances = {};
    var currentWalletId = res.wallets.currentWallet.id;
    for (var key in await services.download.unspents.getSymbols()) {
      var security = res.securities.bySymbol.getAll(key).firstOrNull ??
          Security(symbol: key, securityType: SecurityType.RavenAsset);
      //if (securities.isEmpty) {
      //  // security isn't saved to the database yet
      //  return;
      //}
      var confirmed =
          await services.download.unspents.totalConfirmed(currentWalletId, key);
      var unconfirmed = await services.download.unspents
          .totalUnconfirmed(currentWalletId, key);
      if (confirmed + unconfirmed > 0) {
        balances.add(Balance(
            walletId: currentWalletId,
            security: security,
            confirmed: confirmed,
            unconfirmed: unconfirmed));
      }
    }
    await res.balances.saveAll(balances);
  }

  /// Transaction Logic ///////////////////////////////////////////////////////

  Future<List<Vout>> collectUTXOs(
      {required int amount, Security? security}) async {
    await services.download.unspents.assertSufficientFunds(
        res.wallets.currentWallet.id, amount, security?.symbol);
    var gathered = 0;
    var unspents =
        (await services.download.unspents.getUnspents(security?.symbol))
            .toList();
    var collection = <Vout>[];
    final _random = Random();
    while (amount - gathered > 0) {
      var randomIndex = _random.nextInt(unspents.length);
      var unspent = unspents[randomIndex];
      unspents.removeAt(randomIndex);
      gathered += unspent.value;
      collection.add(res.vouts.byTransactionPosition
          .getOne(unspent.txHash, unspent.txPos)!);
    }
    return collection;
  }

  /// Wallet Aggregation Logic ////////////////////////////////////////////////

  /// as of 517 - we build all the balances each time
  List<Balance> walletBalances(Wallet wallet) {
    //Map<Security, Balance> balancesBySecurity = {};
    //for (var balance in wallet.balances) {
    //  if (!balancesBySecurity.containsKey(balance.security)) {
    //    balancesBySecurity[balance.security] = balance;
    //  } else {
    //    balancesBySecurity[balance.security] =
    //        balancesBySecurity[balance.security]! + balance;
    //  }
    //}
    //return balancesBySecurity.values.toList();
    return wallet.balances;
  }

  Balance walletBalance(Wallet wallet, Security security) {
    var retBalance =
        Balance(walletId: '', confirmed: 0, unconfirmed: 0, security: security);
    for (var balance in wallet.balances) {
      if (balance.security == security) {
        retBalance = retBalance + balance;
      }
    }
    return retBalance;
  }
}
/*
class TrimUnspent with EquatableMixin {
  String transactionId;
  int position;
  int rvnValue;
  int assetValue;
  Address address;
  String lockingScript;

  TrimUnspent({
    required this.transactionId,
    required this.position,
    required this.rvnValue,
    required this.assetValue,
    required this.address,
    required this.lockingScript,
  });

  factory TrimUnspent.fromScripthashUnspent(ScripthashUnspent given) {
    var isRVN = given.symbol == null ||
        given.symbol == '' ||
        given.symbol == 'RVN' ||
        given.symbol == 'Ravencoin';
    return TrimUnspent(
      transactionId: given.txHash,
      position: given.txPos,
      rvnValue: isRVN ? given.value : 0,
      assetValue: isRVN ? 0 : given.value,
      address: ,
      lockingScript: '',
    );
  }

  @override
  List<Object> get props => [
        transactionId,
        position,
        rvnValue,
        assetValue,
      ];

  @override
  String toString() {
    return 'TrimUnspent(transactionId: $transactionId, position: $position, rvnValue: $rvnValue, assetValue: $assetValue)';
  }

  bool get isAsset => assetValue > rvnValue;
}
*/