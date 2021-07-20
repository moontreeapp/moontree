import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:raven/derivation_path.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:ravencoin/ravencoin.dart';

import 'boxes.dart';
import 'models/hd_node.dart';
import 'models/node_exposure.dart';
import 'models/account_stored.dart';

class CacheEmpty implements Exception {
  String cause;
  CacheEmpty([this.cause = 'Error! Please deriveNodes first.']);
}

class InsufficientFunds implements Exception {
  String cause;
  InsufficientFunds([this.cause = 'Error! Insufficient funds.']);
}

class nodeLocation {
  int index;
  NodeExposure exposure;

  nodeLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class Account {
  final NetworkType network;
  final Uint8List symmetricallyEncryptedSeed;
  final String name;
  final HDWallet _wallet;
  final String accountId;

  Account(this.network, this.symmetricallyEncryptedSeed, cipher,
      {this.name = 'Wallet'})
      : _wallet = HDWallet.fromSeed(cipher.decrypt(symmetricallyEncryptedSeed),
            network: network),
        accountId = sha256
            .convert(cipher.decrypt(symmetricallyEncryptedSeed))
            .toString();

  Account.bySeed(this.network, seed, cipher, {this.name = 'First Wallet'})
      : _wallet = HDWallet.fromSeed(seed, network: network),
        accountId = sha256.convert(seed).toString(),
        symmetricallyEncryptedSeed = cipher.encrypt(seed);

  factory Account.fromAccountStored(AccountStored accountStored, cipher) {
    return Account(
        accountStored.network, accountStored.symmetricallyEncryptedSeed, cipher,
        name: accountStored.name);
  }

  HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet = _wallet.derivePath(
        getDerivationPath(index, exposure: exposure, wif: network.wif));
    return HDNode(index, _wallet.seed!,
        exposure: exposure, networkWif: network.wif);
  }

  List<String> get accountInternals {
    var ounordered = Truth.instance.scripthashAccountIdInternal
        .filterKeysByValueString(accountId)
        .toList();
    var orders =
        Truth.instance.scripthashOrderInternal.filterAllByKeys(ounordered);
    var keys = orders.keys.toList(growable: false)
      ..sort((k1, k2) => orders[k1]!.compareTo(orders[k2]!));
    return keys
        .map((element) => element as String)
        .toList(); // List<dynamic> -> List<String>
  }

  /// why should we care if externals are ordered? we'll be consistent
  List<String> get accountExternals {
    var ounordered = Truth.instance.scripthashAccountIdExternal
        .filterKeysByValueString(accountId)
        .toList();
    var orders =
        Truth.instance.scripthashOrderExternal.filterAllByKeys(ounordered);
    var keys = orders.keys.toList(growable: false)
      ..sort((k1, k2) => orders[k1]!.compareTo(orders[k2]!));
    return keys
        .map((element) => element as String)
        .toList(); // List<dynamic> -> List<String>
    // unordered
    //return Truth.instance.scripthashAccountIdExternal
    //    .filterKeysByValueString(accountId);
  }

  List<String> get accountScripthashes {
    return [...accountInternals, ...accountExternals];
  }

  /// triggered by watching accounts and others...
  Future deriveBatch(NodeExposure exposure, [int batchSize = 10]) async {
    Box box;
    Box boxOrder;
    if (exposure == NodeExposure.Internal) {
      box = Truth.instance.scripthashAccountIdInternal;
      boxOrder = Truth.instance.scripthashOrderInternal;
    } else {
      box = Truth.instance.scripthashAccountIdExternal;
      boxOrder = Truth.instance.scripthashOrderExternal;
    }
    var index = box.countByValueString(accountId);
    for (var i = 0; i < batchSize; i++) {
      var hash = node(index, exposure: exposure).scripthash;
      //print(index.toString() + ' ' + exposure.toString() + ' ' + hash);
      await box.put(hash, accountId);
      await boxOrder.put(hash, index);
      index = index + 1;
    }
  }

  /// triggered by watching accounts and others...
  Future deriveNode(NodeExposure exposure) async {
    await deriveBatch(exposure, 1);
  }

  int getBalance() {
    return Truth.instance.getAccountBalance(this);
  }

  /// returns the next internal or external node without a history
  HDNode getNextEmptyNode([NodeExposure exposure = NodeExposure.Internal]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var i = 0;
    for (var scripthash in exposure == NodeExposure.Internal
        ? accountInternals
        : accountExternals) {
      if (Truth.instance.histories
          .getAsList<ScripthashHistory>(scripthash)
          .isEmpty) {
        return node(i, exposure: exposure);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return node(i + 1, exposure: exposure);
  }

  SortedList<ScripthashUnspent> sortedUTXOs() {
    var sortedList = SortedList<ScripthashUnspent>(
        (ScripthashUnspent a, ScripthashUnspent b) =>
            a.value.compareTo(b.value));
    sortedList.addAll(
        Truth.instance.accountUnspents.getAsList<ScripthashUnspent>(accountId));
    return sortedList;
  }

  /// returns the smallest number of inputs to satisfy the amount
  List<ScripthashUnspent> collectUTXOs(int amount,
      [List<ScripthashUnspent>? except]) {
    var ret = <ScripthashUnspent>[];

    if (getBalance() < amount) {
      throw InsufficientFunds();
    }
    var utxos = sortedUTXOs();
    utxos.removeWhere((utxo) => (except ?? []).contains(utxo));

    /* can we find an ideal singular utxo? */
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].value >= amount) {
        return [utxos[i]];
      }
    }

    /* what combinations of utxo's must we return?
    lets start by grabbing the largest one
    because we know we can consume it all without producing change...
    and lets see how many times we can do that */
    var remainder = amount;
    for (var i = utxos.length - 1; i >= 0; i--) {
      if (remainder < utxos[i].value) {
        break;
      }
      ret.add(utxos[i]);
      remainder = (remainder - utxos[i].value).toInt();
    }
    // Find one last UTXO, starting from smallest, that satisfies the remainder
    ret.add(utxos.firstWhere((utxo) => utxo.value >= remainder));
    return ret;
  }

  nodeLocation? getNodeLocationOf(scripthash) {
    var i = 0;
    for (var internalScripthash in accountInternals) {
      if (internalScripthash == scripthash) {
        return nodeLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var internalScripthash in accountExternals) {
      if (internalScripthash == scripthash) {
        return nodeLocation(i, NodeExposure.External);
      }
      i = i + 1;
    }
  }
}
