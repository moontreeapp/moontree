/// balances are by wallet
/// if you want the balance of a subwallet (address) then get it from Histories.

// ignore_for_file: omit_local_variable_types
import 'dart:math';
import 'package:ravencoin_back/ravencoin_back.dart';

class BalanceService {
  /// asks the server for balances
  /// But as it turns out we have to get the the status of every address anyway
  /// so grabbing their unspents is just as fast as grabbing their balances
  /// so we just do that instead (recalculateAllBalances)
  Future calculateAllBalances({Set<Wallet>? wallets}) async {
    wallets = pros.wallets.records.toSet();

    //for (var wallet in wallets) {
    //  for (var address in wallet.addresses) {
    //    // ask the server for the assets and balances for this address
    //    // sum them up and save them as a balance
    //    // balances.add(Balance(
    //    //     walletId: walletId,
    //    //     security: security,
    //    //     confirmed: confirmed,
    //    //     unconfirmed: unconfirmed));
    //  }
    //}
    ////await pros.balances.saveAll(balances);
  }

  /// recalculates the balance of every symbol in every wallet
  Future recalculateAllBalances({Set<String>? walletIds}) async {
    walletIds = walletIds ?? pros.wallets.ids;
    Set<Balance> balances = {};
    await pros.balances.removeAllByIds(walletIds);
    for (var walletId in walletIds) {
      for (var symbol in pros.unspents.getSymbolsByWallet(walletId)) {
        var security = pros.securities.primaryIndex
                .getOne(symbol, pros.settings.chain, pros.settings.net) ??
            Security(
              symbol: symbol,
              chain: pros.settings.chain,
              net: pros.settings.net,
            );
        var confirmed = pros.unspents.totalConfirmed(
          walletId,
          symbol: symbol,
          chain: security.chain,
          net: security.net,
        );
        var unconfirmed = pros.unspents.totalUnconfirmed(
          walletId,
          symbol: symbol,
          chain: security.chain,
          net: security.net,
        );
        if (confirmed + unconfirmed > 0) {
          balances.add(Balance(
              walletId: walletId,
              security: security,
              confirmed: confirmed,
              unconfirmed: unconfirmed));
        }
      }
    }
    await pros.balances.saveAll(balances);
  }

  /// Transaction Logic ///////////////////////////////////////////////////////

  Future<List<Vout>> collectUTXOs({
    required String walletId,
    required int amount,
    Security? security,
  }) async {
    pros.unspents.assertSufficientFunds(
      pros.wallets.currentWallet.id,
      amount,
      symbol: security?.symbol,
      chain: security?.chain ?? pros.settings.chain,
      net: security?.net ?? pros.settings.net,
    );
    var gathered = 0;
    var unspents =
        (pros.unspents.byWalletSymbol.getAll(walletId, security?.symbol))
            .toList();
    var collection = <Vout>[];
    // initialize Random with a hidden deterministic seed
    final _random =
        Random(unspents.map((e) => e.transactionId).join().hashCode);
    while (amount - gathered > 0) {
      var randomIndex = _random.nextInt(unspents.length);
      var unspent = unspents[randomIndex];
      unspents.removeAt(randomIndex);
      var vout = unspent.vout;
      if (vout == null) {
        await services.download.history.getAndSaveTransactions(
          {unspent.transactionId},
        );
        vout = unspent.vout!;
      }
      //if (usedUtxos == null || !usedUtxos.contains(vout)) {
      gathered += unspent.value;
      collection.add(vout);
      //}
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
    required this.coinValue,
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
  List<Object> get props => <Object>[
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
