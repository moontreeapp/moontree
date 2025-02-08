import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart' show hex;
import 'package:magic/domain/wallet/sign/sign_message.dart';
import 'package:wallet_utils/wallet_utils.dart' show WalletBase, ECPair;
import 'package:wallet_utils/wallet_utils.dart' as wu;
import 'package:flutter/foundation.dart';
import 'package:magic/utils/logger.dart';

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

  /// Signs a message with the private key of the wallet.
  String signCompact(String message) {
    if (kDebugMode) {
      logW('address: $address');
    }
    final String prefix = network.messagePrefix == '\x18Evrmore Signed Message:\n'
      ? 'Evrmore Signed Message:\n'
      : network.messagePrefix;
    return SignMessage(
      message: message,
      prefix: prefix,
    ).signCompact(privateKeyWIF: wif);
  }

  String _getChallenge() =>
      (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).toString();

  /// Returns a payload for authentication.
  ///
  /// The payload contains [message], [address], [publicKey], and [signature]
  /// to be used for authenticating the wallet.
  Map<String, String> authPayload(String address) {
    final String message = _getChallenge();
    var sig = signCompact(message);
    var data = <String, String>{
      'message': message,
      'address': address,
      'pubkey': pubKey!,
      'signature': sig,
    };
    return data;
  }
}
