/// balances are by wallet
/// if you want the balance of a subwallet (address) then get it from Histories.

// ignore_for_file: omit_local_variable_types
import 'dart:math';
import 'package:raven_back/services/wallet_security_pair.dart';
import 'package:raven_back/raven_back.dart';

class BalanceService {
  /// Listener Logic //////////////////////////////////////////////////////////

  /// Get (sum) the balance for a wallet-security pair
  Balance sumBalance(Wallet wallet, Security security) => Balance(
      walletId: wallet.id,
      security: security,
      confirmed: VoutReservoir.whereUnspent(
              given: wallet.vouts, security: security, includeMempool: false)
          .fold(
              0,
              (int sum, Vout vout) =>
                  sum +
                  vout.securityValue(
                      security: res.securities.primaryIndex.getOne(
                          vout.securityId))), // should this be rvnValue always?
      unconfirmed:
          VoutReservoir.whereUnconfirmed(given: wallet.vouts, security: security).fold(
              0,
              (sum, vout) =>
                  sum +
                  vout.securityValue(
                      security: res.securities.primaryIndex.getOne(
                          vout.securityId)))); // should this be rvnValue always?

  /// If there is a change in its history, recalculate a balance. Return a list
  /// of such res.balances.
  /// it has been seen in an edge case that this can produce the wrong results:
  /// when we have a weird situtation that we've sent stuff to ourselves
  /// mutliple times on the same addresses. Thus, the waiter instead
  /// recalculates the entire the balance every time.
  Iterable<Balance> getChangedBalances(List<Change> changes) =>
      securityPairsFromVoutChanges(changes)
          .map((pair) => sumBalance(pair.wallet, pair.security));

  /// Same as getChangedBalances, but saves them all as well.
  Future<Iterable<Balance>> saveChangedBalances(List<Change> changes) async {
    var changed = getChangedBalances(changes);
    await res.balances.saveAll(changed.toList());
    return changed;
  }

  Iterable<Balance> recalculateSpecificBalances(List<Vout> givenVouts) =>
      securityPairsFromVouts(givenVouts)
          .map((pair) => sumBalance(pair.wallet, pair.security));

  Future recalculateAllBalances() async {
    // wont work when it needs to until we save asset data when we save unspents
    for (var key in await services.download.unspents.getSymbols()) {
      var securities = res.securities.bySymbol.getAll(key);
      if (securities.isEmpty) {
        // security isn't saved to the database yet
        return;
      }
      await res.balances.save(Balance(
          walletId: res.wallets.currentWallet.id,
          security: securities.first,
          confirmed: await services.download.unspents.totalConfirmed(key),
          unconfirmed: await services.download.unspents.totalUnconfirmed(key)));
    }
  }

  /// a good testing heuristic for verfiying transactions are correctly downloaded.
  Future recalculateAllBalancesFromTransactions() async =>
      await res.balances.saveAll(recalculateSpecificBalances(res.vouts.data
          //VoutReservoir.whereUnspent(includeMempool: false)
          .where((Vout vout) => vout.transaction?.confirmed ?? false)
          .toList()));

  Future recalculateRVNBalance() async => await res.balances.save(Balance(
      walletId: res.wallets.currentWallet.id,
      security: res.securities.RVN,
      confirmed: await services.download.unspents
          .totalConfirmed(res.securities.RVN.symbol),
      unconfirmed: await services.download.unspents
          .totalUnconfirmed(res.securities.RVN.symbol)));

  /// Transaction Logic ///////////////////////////////////////////////////////

  Future<List<Vout>> collectUTXOs(
      {required int amount, Security? security}) async {
    await services.download.unspents
        .assertSufficientFunds(amount, security?.symbol);
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

  List<Balance> walletBalances(Wallet wallet) {
    Map<Security, Balance> balancesBySecurity = {};
    for (var balance in wallet.balances) {
      if (!balancesBySecurity.containsKey(balance.security)) {
        balancesBySecurity[balance.security] = balance;
      } else {
        balancesBySecurity[balance.security] =
            balancesBySecurity[balance.security]! + balance;
      }
    }
    return balancesBySecurity.values.toList();
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

  List<Balance> addressesBalances(List<Address> addresses) {
    Map<Security, Balance> balancesBySecurity = {};
    var addressBalances = recalculateSpecificBalances(
        addresses.map((a) => a.vouts).expand((i) => i).toList());
    for (var balance in addressBalances) {
      if (!balancesBySecurity.containsKey(balance.security)) {
        balancesBySecurity[balance.security] = balance;
      } else {
        balancesBySecurity[balance.security] =
            balancesBySecurity[balance.security]! + balance;
      }
    }
    return balancesBySecurity.values.toList();
  }
}
