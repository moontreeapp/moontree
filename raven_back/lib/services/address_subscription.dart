import 'dart:async';

import 'package:quiver/iterables.dart';
import 'package:raven/reservoirs/address.dart';
import 'package:raven/reservoirs/history.dart';
import 'package:raven/reservoirs/wallets/leader.dart';
import 'package:raven/services/leaders.dart' show AddressDerivationService;
import 'package:raven/services/service.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

import '../records.dart';
import '../utils/buffer_count_window.dart';

class ScripthashHistoryRow {
  final Address address;
  final List<ScripthashHistory> history;
  final List<ScripthashUnspent> unspent;
  final List<ScripthashUnspent> assetUnspent;

  ScripthashHistoryRow(
      this.address, this.history, this.unspent, this.assetUnspent);
}

class ScripthashHistoriesData {
  final List<Address> addresses;
  final List<List<ScripthashHistory>> histories;
  final List<List<ScripthashUnspent>> unspents;
  final List<List<ScripthashUnspent>> assetUnspents;

  ScripthashHistoriesData(
      this.addresses, this.histories, this.unspents, this.assetUnspents);

  Iterable<ScripthashHistoryRow> get zipped =>
      zip([addresses, histories, unspents]).map((e) => ScripthashHistoryRow(
          e[0] as Address,
          e[1] as List<ScripthashHistory>,
          e[2] as List<ScripthashUnspent>,
          e[3] as List<ScripthashUnspent>));
}

class AddressSubscriptionService extends Service {
  LeaderWalletReservoir leaders;
  AddressReservoir addresses;
  HistoryReservoir histories;
  RavenElectrumClient client;
  AddressDerivationService addressDerivationService;
  Map<String, StreamSubscription> subscriptionHandles = {};
  List<StreamSubscription> listeners = [];

  StreamController<Address> addressesNeedingUpdate = StreamController();

  AddressSubscriptionService(this.leaders, this.addresses, this.histories,
      this.client, this.addressDerivationService)
      : super();

  @override
  void init() {
    subscribeToExistingAddresses();

    listeners.add(addressesNeedingUpdate.stream
        .bufferCountTimeout(10, Duration(milliseconds: 50))
        .listen((changedAddresses) async {
      saveScripthashHistoryData(
          await getScripthashHistoriesData(changedAddresses));

      addressDerivationService.maybeDeriveNewAddresses(changedAddresses);
    }));

    listeners.add(addresses.changes.listen((change) {
      change.when(
          added: (added) {
            Address address = added.data;
            addressNeedsUpdating(address);
            subscribe(address);
          },
          updated: (updated) {},
          removed: (removed) {
            unsubscribe(removed.id as String);
          });
    }));
  }

  @override
  void deinit() {
    for (var listener in listeners) {
      listener.cancel();
    }
  }

  void addressNeedsUpdating(Address address) {
    addressesNeedingUpdate.sink.add(address);
  }

  void subscribe(Address address) {
    var stream = client.subscribeScripthash(address.scripthash);
    subscriptionHandles[address.scripthash] = stream.listen((status) {
      addressNeedsUpdating(address);
    });
  }

  void unsubscribe(String scripthash) {
    subscriptionHandles[scripthash]!.cancel();
  }

  void subscribeToExistingAddresses() {
    for (var address in addresses) {
      subscribe(address);
    }
  }

  Future<ScripthashHistoriesData> getScripthashHistoriesData(
      List<Address> changedAddresses) async {
    var scripthashes =
        changedAddresses.map((address) => address.scripthash).toList();
    // ignore: omit_local_variable_types
    List<List<ScripthashHistory>> histories =
        await client.getHistories(scripthashes);
    // ignore: omit_local_variable_types
    List<List<ScripthashUnspent>> unspents =
        await client.getUnspents(scripthashes);
    // ignore: omit_local_variable_types
    List<List<ScripthashUnspent>> assetUnspents =
        await client.getAssetUnspents(scripthashes);
    return ScripthashHistoriesData(
        changedAddresses, histories, unspents, assetUnspents);
  }

  void saveScripthashHistoryData(ScripthashHistoriesData data) async {
    data.zipped.forEach((row) {
      histories.saveAll(combineHistoryAndUnspents(row));
    });
  }

  List<History> combineHistoryAndUnspents(ScripthashHistoryRow row) {
    var newHistories = <History>[];
    for (var history in row.history) {
      newHistories.add(History.fromScripthashHistory(row.address.accountId,
          row.address.walletId, row.address.scripthash, history));
    }
    for (var unspent in row.unspent) {
      newHistories.add(History.fromScripthashUnspent(row.address.accountId,
          row.address.walletId, row.address.scripthash, unspent));
    }
    for (var unspent in row.assetUnspent) {
      newHistories.add(History.fromScripthashUnspent(row.address.accountId,
          row.address.walletId, row.address.scripthash, unspent));
    }
    return newHistories;
  }
}
