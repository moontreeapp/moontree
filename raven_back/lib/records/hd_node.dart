import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:convert/convert.dart' show hex;

import 'node_exposure.dart';

part 'hd_node.g.dart';

@HiveType(typeId: 6)
class HDNode {
  @HiveField(0)
  int index;

  @HiveField(1)
  Uint8List seed;

  @HiveField(2)
  int networkWif;

  @HiveField(3)
  NodeExposure exposure;

  HDNode(this.index, this.seed,
      {this.networkWif = /* testnet */ 0xef,
      this.exposure = NodeExposure.External});

  NetworkType get network => ravencoinNetworks[networkWif]!;

  HDWallet get wallet => HDWallet.fromSeed(seed, network: network);

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
