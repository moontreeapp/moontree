import 'dart:cli';
import 'dart:html';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:hive/hive.dart';
import 'package:raven/raven_networks.dart';
import 'network_params.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'boxes.dart' as boxes;
import 'package:encrypt/encrypt.dart';

export 'raven_networks.dart';

class CacheEmpty implements Exception {
  String cause;
  CacheEmpty([this.cause = 'Error! Please deriveNodes first.']);
}

class InsufficientFunds implements Exception {
  String cause;
  InsufficientFunds([this.cause = 'Error! Insufficient funds.']);
}

/* delete
//@HiveType(typeId: 0)
class CachedNode {
  //@HiveField(0)
  HDNode node;

  //@HiveField(1)
  ScripthashBalance balance;

  //@HiveField(2)
  List<ScripthashUnspent> unspent;

  //@HiveField(3)
  List<ScripthashHistory> history;

  CachedNode(this.node,
      {required this.balance, required this.unspent, required this.history});
}

class UTXO {
  ScripthashUnspent unspent;
  NodeExposure exposure;
  int nodeIndex;

  UTXO(this.unspent, this.exposure, this.nodeIndex);
}
*/
Uint8List decrypt(encryptedSeed) {
  return encryptedSeed;
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

  Uint8List get seed => decrypt(symmetricallyEncryptedSeed);

  AccountStored(this.symmetricallyEncryptedSeed,
      {networkParams, this.name = 'First Wallet'})
      : params = networkParams ?? ravencoinTestnet,
        accountId =
            sha256.convert(decrypt(symmetricallyEncryptedSeed)).toString();

/*
  Uint8List decrypt(encryptedSeed) {
    final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
    final key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
    print(encrypted
        .base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
  }
  */
}

class Account {
  final NetworkParams params;
  final Uint8List symmetricallyEncryptedSeed;
  final String name;
  final HDWallet _wallet;
  //final List<CachedNode> cache = [];
  final String accountId;

  // todo on new account:
  //boxes.Truth.instance.accountInternals[accountId] = await Hive.openBox(accountId);
  Account(this.params, this.symmetricallyEncryptedSeed,
      {this.name = 'First Wallet'})
      : _wallet = HDWallet.fromSeed(decrypt(symmetricallyEncryptedSeed),
            network: params.network),
        accountId =
            sha256.convert(decrypt(symmetricallyEncryptedSeed)).toString();

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

  Iterable get accountInternals {
    return boxes.Truth.instance.scripthashAccountIdInternal
        .filterKeysByValueString(accountId);
  }

  Iterable get accountExternals {
    return boxes.Truth.instance.scripthashAccountIdExternal
        .filterKeysByValueString(accountId);
  }

  List get accountScripthashes {
    var scripthashes = [];
    scripthashes.addAll(accountInternals.toList());
    scripthashes.addAll(accountExternals.toList());
    return scripthashes;
  }

/*
  Encrypted encrypt() {
    final plainText = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit';
    final key = Key.fromUtf8('my 32 length key................');
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    print(decrypted); // Lorem ipsum dolor sit amet, consectetur adipiscing elit
    print(encrypted
        .base64); // R4PxiU3h8YoIRqVowBXm36ZcCeNeZ4s1OvVBTfFlZRdmohQqOpPQqD1YecJeZMAop/hZ4OxqgC1WtwvX/hP9mw==
  }
*/

  /// triggered by watching accounts and others...
  Future deriveBatch(NodeExposure exposure, [int batchSize = 10]) async {
    Box box;
    if (exposure == NodeExposure.Internal) {
      box = boxes.Truth.instance.scripthashAccountIdInternal;
    } else {
      box = boxes.Truth.instance.scripthashAccountIdExternal;
    }
    var index = box.countByValueString(accountId);
    for (var i = 0; i < batchSize; i++) {
      var hash = node(index, exposure: exposure).scripthash;
      await box.put(hash, accountId);
      index = index + 1;
    }
  }

  int getBalance() {
    return boxes.Truth.instance.getAccountBalance(this);
  }

  /// returns the next internal node without a history
  HDNode getNextChangeNode() {
    // here we assume .where returns it in order...
    /* not sure this approach guarantees correct order
    var internalScripthashes = boxes.Truth.instance.scripthashAccountIdInternal
        .filterKeysByValueString(accountId);
    var internalHistoriesMap = boxes.Truth.instance.histories
        .filterByKeys(internalScripthashes.toList());
    var i = 0;
    for (var scripthashHistory in internalHistoriesMap) {
      if (scripthashHistory.values[0].isEmpty) {
        return scripthashHistory.keys[0];
      }
      i = i + 1;
    }
    */
    var i = 0;
    for (var scripthash in accountInternals) {
      if (boxes.Truth.instance.histories.get(scripthash)!.isEmpty) {
        return node(i, exposure: NodeExposure.Internal);
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    return node(i + 1, exposure: NodeExposure.Internal);
  }

  /// returns the smallest number of inputs to satisfy the amount
  List<ScripthashUnspent> collectUTXOs(int amount,
      [List<ScripthashUnspent>? except]) {
    var ret = <ScripthashUnspent>[];

    // Insufficient funds?
    if (getBalance() < amount) {
      throw InsufficientFunds();
    }

    var utxos = boxes.Truth.instance.accountUnspents.get(accountId);
    utxos!.removeWhere((utxo) => except!.contains(utxo));

    // can we find an ideal singular utxo?
    for (var i = 0; i < utxos.length; i++) {
      if (utxos[i].value >= amount) {
        return [utxos[i]];
      }
    }

    // what combinations of utxo's must we return?
    // lets start by grabbing the largest one
    // because we know we can consume it all without producing change...
    // and lets see how many times we can do that
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
    return Address.addressToOutputScript(wallet.address, params.network);
  }

  String get scripthash {
    // ignore: omit_local_variable_types
    Digest digest = sha256.convert(outputScript);
    var hash = reverse(digest.bytes);
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wallet.wif, network: params.network);
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
