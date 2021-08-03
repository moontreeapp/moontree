import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:raven/wallets/hd_wallet.dart';
import 'package:ravencoin/ravencoin.dart';

import '../cipher.dart';
import '../records.dart' as records;
import '../records/net.dart';
import '../models.dart' as models;

extension Scripthash on HDWallet {
  Uint8List get outputScript {
    return Address.addressToOutputScript(address!, network)!;
  }

  String get scripthash {
    var digest = sha256.convert(outputScript);
    var hash = digest.bytes.reversed.toList();
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wif!, networks: ravencoinNetworks);
  }
}

class CacheEmpty implements Exception {
  String cause;
  CacheEmpty([this.cause = 'Error! Please deriveNodes first.']);
}

class InsufficientFunds implements Exception {
  String cause;
  InsufficientFunds([this.cause = 'Error! Insufficient funds.']);
}

const DEFAULT_CIPHER = NoCipher();

class LeaderWallet extends DerivedWallet {
  LeaderWallet(seed, {net = Net.Test, cipher = const NoCipher()})
      : super(seed, net: net, cipher: cipher);

  factory LeaderWallet.fromEncryptedSeed(encryptedSeed,
      {name = 'Wallet', net = Net.Test, cipher = const NoCipher()}) {
    return LeaderWallet(cipher.decrypt(encryptedSeed),
        net: net, cipher: cipher);
  }

  factory LeaderWallet.fromRecord(records.LeaderWallet record,
      {cipher = const NoCipher()}) {
    return LeaderWallet(cipher.decrypt(record.encryptedSeed),
        net: record.net, cipher: cipher);
  }

  records.LeaderWallet toRecord() {
    return records.LeaderWallet(encryptedSeed, net: net);
  }

  //// getters /////////////////////////////////////////////////////////////////

  //int get balance => get all my addresses and sum balance (use service)

  //// Derive Wallet ///////////////////////////////////////////////////////////

  models.Address deriveAddress(int hdIndex, records.NodeExposure exposure) {
    var wallet = deriveWallet(hdIndex, exposure);
    return models.Address(wallet.scripthash, wallet.address!, id, hdIndex,
        exposure: exposure, net: net);
  }

  //// Sending Functionality ///////////////////////////////////////////////////

  //SortedList<ScripthashUnspent> sortedUTXOs() {
  //  var sortedList = SortedList<ScripthashUnspent>(
  //      (ScripthashUnspent a, ScripthashUnspent b) =>
  //          a.value.compareTo(b.value));
  //  sortedList.addAll(
  //      Truth.instance.accountUnspents.getAsList<ScripthashUnspent>(accountId));
  //  return sortedList;
  //}
//
  ///// returns the smallest number of inputs to satisfy the amount
  //List<ScripthashUnspent> collectUTXOs(int amount,
  //    [List<ScripthashUnspent>? except]) {
  //  var ret = <ScripthashUnspent>[];
//
  //  if (balance < amount) {
  //    throw InsufficientFunds();
  //  }
  //  var utxos = sortedUTXOs();
  //  utxos.removeWhere((utxo) => (except ?? []).contains(utxo));
//
  //  /* can we find an ideal singular utxo? */
  //  for (var i = 0; i < utxos.length; i++) {
  //    if (utxos[i].value >= amount) {
  //      return [utxos[i]];
  //    }
  //  }
//
  //  /* what combinations of utxo's must we return?
  //  lets start by grabbing the largest one
  //  because we know we can consume it all without producing change...
  //  and lets see how many times we can do that */
  //  var remainder = amount;
  //  for (var i = utxos.length - 1; i >= 0; i--) {
  //    if (remainder < utxos[i].value) {
  //      break;
  //    }
  //    ret.add(utxos[i]);
  //    remainder = (remainder - utxos[i].value).toInt();
  //  }
  //  // Find one last UTXO, starting from smallest, that satisfies the remainder
  //  ret.add(utxos.firstWhere((utxo) => utxo.value >= remainder));
  //  return ret;
  //}
}
