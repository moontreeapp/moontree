import 'package:equatable/equatable.dart';

import '../../raven_electrum_client.dart';

class ScripthashBalance with EquatableMixin {
  int confirmed;
  int unconfirmed;
  ScripthashBalance(this.confirmed, this.unconfirmed);

  int get value {
    return confirmed + unconfirmed;
  }

  @override
  List<Object> get props => [confirmed, unconfirmed];

  @override
  String toString() {
    return 'ScripthashBalance(confirmed: $confirmed, unconfirmed: $unconfirmed)';
  }
}

class ScripthashAssetBalances with EquatableMixin {
  Map<String, int> confirmed;
  Map<String, int> unconfirmed;
  ScripthashAssetBalances(this.confirmed, this.unconfirmed);

  int value(String ticker) {
    var confirmedCollected = confirmed.map((key, value) =>
        key == ticker ? MapEntry(ticker, value) : MapEntry(ticker, 0));
    var unconfirmedCollected = unconfirmed.map((key, value) =>
        key == ticker ? MapEntry(ticker, value) : MapEntry(ticker, 0));
    return (confirmedCollected.values.fold(
            0, (previousValue, value) => previousValue ?? 0 + value) as int) +
        (unconfirmedCollected.values.fold(
            0, (previousValue, value) => previousValue ?? 0 + value) as int);
  }

  @override
  List<Object> get props => [confirmed, unconfirmed];

  @override
  String toString() {
    return 'ScripthashAssetBalances(confirmed: $confirmed, unconfirmed: $unconfirmed)';
  }
}

extension GetBalanceMethod on RavenElectrumClient {
  Future<ScripthashBalance> getBalance(scripthash) async {
    dynamic balance =
        await request('blockchain.scripthash.get_balance', [scripthash]);
    return ScripthashBalance(balance['confirmed'], balance['unconfirmed']);
  }

  /// returns balances in the same order as scripthashes passed in
  Future<List<ScripthashBalance>> getBalances(List<String> scripthashes) async {
    var futures = <Future<ScripthashBalance>>[];
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getBalance(scripthash));
      }
    });
    List<ScripthashBalance> results =
        await Future.wait<ScripthashBalance>(futures);
    return results;
  }

  Future<ScripthashAssetBalances> getAssetBalance(scripthash) async {
    dynamic balance =
        await request('blockchain.scripthash.get_asset_balance', [scripthash]);
    return ScripthashAssetBalances(
        balance['confirmed'], balance['unconfirmed']);
  }

  /// returns balances in the same order as scripthashes passed in
  Future<List<ScripthashAssetBalances>> getAssetBalances(
    List<String> scripthashes,
  ) async {
    var futures = <Future<ScripthashAssetBalances>>[];
    peer.withBatch(() {
      for (var scripthash in scripthashes) {
        futures.add(getAssetBalance(scripthash));
      }
    });
    List<ScripthashAssetBalances> results =
        await Future.wait<ScripthashAssetBalances>(futures);
    return results;
  }
}
