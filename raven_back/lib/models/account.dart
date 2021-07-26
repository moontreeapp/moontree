import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:raven/cipher.dart';
import 'package:raven/derivation_path.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:ravencoin/ravencoin.dart';

import '../boxes.dart';
import '../records.dart' as records;

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
  records.NodeExposure exposure;

  nodeLocation(int locationIndex, records.NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

const DEFAULT_CIPHER = NoCipher();

class Account {
  final NetworkType network;
  final Uint8List encryptedSeed;
  final String name;
  final records.Account? record;
  late final String accountId;
  late final HDWallet wallet;
  late final Cipher cipher;

  Account(seed,
      {this.name = 'Wallet',
      this.network = ravencoin,
      this.record,
      this.cipher = const NoCipher()})
      : wallet = HDWallet.fromSeed(seed, network: network),
        accountId = sha256.convert(seed).toString(),
        encryptedSeed = cipher.encrypt(seed);

  factory Account.fromEncryptedSeed(encryptedSeed,
      {name = 'Wallet',
      network = ravencoin,
      record,
      cipher = const NoCipher()}) {
    return Account(cipher.decrypt(encryptedSeed),
        name: name, network: network, record: record, cipher: cipher);
  }

  factory Account.fromRecord(records.Account record,
      {cipher = const NoCipher()}) {
    return Account(cipher.decrypt(record.encryptedSeed),
        name: record.name,
        network: record.network,
        record: record,
        cipher: cipher);
  }

  @override
  String toString() {
    return 'Account($name, $accountId)';
  }

  records.HDNode node(int index, {exposure = records.NodeExposure.External}) {
    var wallet = this.wallet.derivePath(
        getDerivationPath(index, exposure: exposure, wif: network.wif));
    return records.HDNode(index, wallet.base58Priv!,
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
  Future deriveBatch(records.NodeExposure exposure,
      [int batchSize = 10]) async {
    Box box;
    Box boxOrder;
    if (exposure == records.NodeExposure.Internal) {
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
  Future deriveNode(records.NodeExposure exposure) async {
    await deriveBatch(exposure, 1);
  }

  int getBalance() {
    return Truth.instance.getAccountBalance(this);
  }

  /// returns the next internal or external node without a history
  records.HDNode getNextEmptyNode(
      [records.NodeExposure exposure = records.NodeExposure.Internal]) {
    // ensure valid exposure
    exposure = exposure == records.NodeExposure.Internal
        ? records.NodeExposure.Internal
        : records.NodeExposure.External;
    var i = 0;
    for (var scripthash in exposure == records.NodeExposure.Internal
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
        return nodeLocation(i, records.NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var internalScripthash in accountExternals) {
      if (internalScripthash == scripthash) {
        return nodeLocation(i, records.NodeExposure.External);
      }
      i = i + 1;
    }
  }
}
