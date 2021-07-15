import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:ravencoin/ravencoin.dart';
import 'network_params.dart';
import 'raven_networks.dart';
import 'boxes.dart';
import 'cipher.dart';

export 'raven_networks.dart';

Cipher cipher = Cipher(defaultInitializationVector);

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

class AccountStored {
  Uint8List symmetricallyEncryptedSeed;
  NetworkParams? params;
  String name;
  String accountId;

  Uint8List get seed => cipher.decrypt(symmetricallyEncryptedSeed);

  AccountStored(this.symmetricallyEncryptedSeed,
      {networkParams, this.name = 'First Wallet'})
      : params = networkParams ?? ravencoinTestnet,
        accountId = sha256
            .convert(cipher.decrypt(symmetricallyEncryptedSeed))
            .toString();
}

class Account {
  final NetworkParams params;
  final Uint8List symmetricallyEncryptedSeed;
  final String name;
  final HDWallet _wallet;
  final String accountId;

  Account(this.params, this.symmetricallyEncryptedSeed,
      {this.name = 'First Wallet'})
      : _wallet = HDWallet.fromSeed(cipher.decrypt(symmetricallyEncryptedSeed),
            network: params.network),
        accountId = sha256
            .convert(cipher.decrypt(symmetricallyEncryptedSeed))
            .toString();

  Account.bySeed(this.params, seed, {this.name = 'First Wallet'})
      : _wallet = HDWallet.fromSeed(seed, network: params.network),
        accountId = sha256.convert(seed).toString(),
        symmetricallyEncryptedSeed = cipher.encrypt(seed);

  factory Account.fromAccountStored(AccountStored accountStored) {
    return Account(accountStored.params ?? ravencoinTestnet,
        accountStored.symmetricallyEncryptedSeed,
        name: accountStored.name);
  }

  HDNode node(int index, {exposure = NodeExposure.External}) {
    var wallet =
        _wallet.derivePath(params.derivationPath(index, exposure: exposure));
    return HDNode(params, wallet, index, exposure);
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
      print(index.toString() + ' ' + exposure.toString() + ' ' + hash);
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

  /// returns the next internal node without a history
  HDNode getNextChangeNode() {
    var i = 0;
    for (var scripthash in accountInternals) {
      if (Truth.instance.histories
          .getAsList<ScripthashHistory>(scripthash)
          .isEmpty) {
        return node(i, exposure: NodeExposure.Internal);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return node(i + 1, exposure: NodeExposure.Internal);
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

List<int> reverse(List<int> hex) {
  var buffer = Uint8List(hex.length);
  for (var i = 0, j = hex.length - 1; i <= j; ++i, --j) {
    buffer[i] = hex[j];
    buffer[j] = hex[i];
  }
  return buffer;
}

class HDNode {
  NetworkParams params;
  HDWallet wallet;
  int index;
  NodeExposure exposure;

  HDNode(this.params, this.wallet, this.index, this.exposure);

  Uint8List get outputScript {
    return Address.addressToOutputScript(wallet.address!, params.network)!;
  }

  String get scripthash {
    // ignore: omit_local_variable_types
    Digest digest = sha256.convert(outputScript);
    var hash = reverse(digest.bytes);
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wallet.wif!, networks: ravencoinNetworks);
  }
}

enum NodeExposure { Internal, External }

String exposureToDerivationPathPart(NodeExposure exposure) {
  switch (exposure) {
    case NodeExposure.External:
      return '0';
    case NodeExposure.Internal:
      return '1';
  }
}
