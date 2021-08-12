import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart' show WalletBase, ECPair;
import 'package:ravencoin/ravencoin.dart' as rc;
import 'package:raven/utils/cipher.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  Wallet() : super();

  Cipher get cipher => const NoCipher();
}

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
