import 'dart:async';

import 'package:raven/models.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/services/service.dart';

class AddressesService extends Service {
  AccountReservoir accounts;
  WalletReservoir wallets;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  AddressesService(this.accounts, this.wallets, this.addresses, this.histories)
      : super();

  @override
  void init() {
    //AddressSubscriptionService(wallets, addresses, client);
    listener = addresses.changes.listen((change) {
      change.when(added: (added) {
        // pass - see AddressSubscriptionService
      }, updated: (updated) {
        Address address = updated.data;
        //update account balance, not wallet balance.
        //accounts.setBalances(
        //    address.accountId, collectBalancesOf(address.accountId));
      }, removed: (removed) {
        // always triggered by account removal
        histories.removeHistories(removed.id as String);
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }

  // Balance calculateBalance(String accountId) {
  //   return addresses.byAccount.getAll(accountId).fold(
  //       Balance(0, 0),
  //       (previousValue, element) => Balance(
  //           previousValue.confirmed + (element as Balance).confirmed,
  //           previousValue.unconfirmed + element.unconfirmed));
  // }

  /// combine all asset and raven balances for all addresses of wallets of account
  //Balances collectBalancesOf(String accountId,
  //    {String? ticker, String index = 'account'}) {
  //  return addresses.indices[index]!
  //      .getAll(accountId)
  //      .map((address) => address.balances)
  //      .fold(
  //          Balances(balances: {}),
  //          (previousValue, balances) =>
  //              Balances.fromTwo(previousValue, balances));

  ///.fold(Map(), (previousValue, balances) => {...previousValue, ...balances});

  //map1 ++ map2.map{ case (k,v) => k -> (v + map1.getOrElse(k,0)) }

  //.where((address) => ticker != null ? (address.balances.ticker == ticker) : true).map((e) => e.);

  //return histories.indices['account']!
  //    .getAll(accountId)
  //    .where((history) => (history as History).value != null)
  //    .fold(
  //      Balance(ticker: ticker, confirmed: 0, unconfirmed: 0),
  //      (previousValue, history) => history.value + previousValue);

  //addresses.indices[index]!
  //    .getAll(accountId)
  //    .where((address) => ticker != null ? (address.balance.ticker == ticker) : true).map((e) => e.);

  //.fold(
  //    Balance(ticker: ticker, confirmed: 0, unconfirmed: 0),
  //    (previousValue, element) => Balance(
  //        ticker: ticker,
  //        confirmed:
  //            previousValue.confirmed + (element as Balance).confirmed,
  //        unconfirmed: previousValue.unconfirmed + element.unconfirmed));
  //}
}
