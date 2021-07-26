import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:convert/convert.dart' show hex;

import 'account.dart';

import '../records/node_exposure.dart';
import '../records/net.dart';

// someone creates a wallet -> 20 addresses are generated -> electrum -> scripthash balances, histories, unspents
// someone deletes the wallet -> we delete the Account -> ??
//   - remove Account record from a Account box
//     - unsubscribe from addresses (scripthash)
//     - delete in-memory addresses
//     - delete in-memory balances, histories, unspents
//     - UI updates

// class AccountWithAddresses {
//   AccountWithAddresses(this.account, this.addresses)
// }

class Address {
  String scripthash;
  String accountId;
  int hdIndex;
  NodeExposure exposure;
  Net net;

  Address(this.scripthash, this.accountId, this.hdIndex,
      {this.net = Net.Test, this.exposure = NodeExposure.External});

  NetworkType get network => networks[net]!;

  HDWallet get wallet {
    // var accounts = Hive.box('accounts');
    // Account account = accounts.get(accountId);
    // account.
    var accounts = HDWallet.fromBase58(base58, network: network);
  }

  Uint8List get outputScript {
    return Address.addressToOutputScript(wallet.address!, network)!;
  }

  String get scripthash {
    var digest = sha256.convert(outputScript);
    var hash = digest.bytes.reversed.toList();
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wallet.wif!, networks: ravencoinNetworks);
  }
}
