import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:equatable/equatable.dart';
import 'package:ravencoin/ravencoin.dart' show WalletBase, ECPair, NetworkType;
import 'package:ravencoin/ravencoin.dart' as rc;

import 'package:raven/utils/cipher.dart';
import 'package:raven/records.dart';

extension Scripthash on WalletBase {
  Uint8List get outputScript {
    return rc.Address.addressToOutputScript(address!, network)!;
  }

  String get scripthash {
    var digest = sha256.convert(outputScript);
    var hash = digest.bytes.reversed.toList();
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wif!, networks: rc.networks);
  }
}

abstract class Wallet extends Equatable {
  final Net net;
  late final Cipher cipher;

  Wallet({this.net = Net.Test, this.cipher = const NoCipher()}) : super();

  NetworkType get network => networks[net]!;

  @override
  List<Object?> get props => [net];
}
