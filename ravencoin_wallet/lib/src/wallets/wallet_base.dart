import 'dart:typed_data';

import '../models/networks.dart';
import '../payments/p2pkh.dart';

abstract class WalletBase {
  P2PKH p2pkh;
  NetworkType network;

  String? get privKey;
  String? get pubKey;
  String? get wif;

  String? get address => p2pkh.data.address;

  WalletBase(this.p2pkh, this.network);

  Uint8List sign(String message);

  bool verify({required String message, required Uint8List signature});
}
