import 'dart:typed_data';

import 'package:magic/domain/wallet/hex.dart';
import 'package:wallet_utils/wallet_utils.dart';

KPWallet keypairWalletFromPubKey(String pubKeyHex, NetworkType network) {
  Uint8List pubKey = hexToBytesPubkey(pubKeyHex);
  final _keyPair = ECPair.fromPublicKey(pubKey, network: network);
  final _p2pkh = P2PKH(
      data: PaymentData(pubkey: _keyPair.publicKey),
      asset: null,
      assetAmount: null,
      assetLiteral: Uint8List(0),
      network: network);
  return KPWallet(_keyPair, _p2pkh, network);
}
