import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:wallet_utils/wallet_utils.dart' show WalletBase, ECPair;
import 'package:wallet_utils/wallet_utils.dart' as wu;

extension ExtendedWalletBase on WalletBase {
  Uint8List get outputScript {
    return wu.Address.addressToOutputScript(address!, network)!;
  }

  String get scripthash {
    final Digest digest = sha256.convert(outputScript);
    final List<int> hash = digest.bytes.reversed.toList();
    return hex.encode(hash);
  }

  ECPair get keyPair {
    return ECPair.fromWIF(wif!, network);
  }
}
