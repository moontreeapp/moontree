import 'dart:typed_data';

import 'package:ravencoin/src/utils/magic_hash.dart';
import 'package:hex/hex.dart';

import 'models/networks.dart';
import 'payments/index.dart' show PaymentData;
import 'payments/p2pkh.dart';
import 'ecpair.dart';

class Wallet {
  ECPair _keyPair;
  P2PKH _p2pkh;

  String? get privKey => HEX.encode(_keyPair.privateKey!);

  String? get pubKey => HEX.encode(_keyPair.publicKey!);

  String? get wif => _keyPair.toWIF();

  String? get address => _p2pkh.data.address;

  NetworkType network;

  Wallet(this._keyPair, this._p2pkh, this.network);

  factory Wallet.random([NetworkType network = ravencoin]) {
    final _keyPair = ECPair.makeRandom(network: network);
    final _p2pkh = new P2PKH(
        data: new PaymentData(pubkey: _keyPair.publicKey), network: network);
    return Wallet(_keyPair, _p2pkh, network);
  }

  factory Wallet.fromWIF(String wif,
      {Map<int, NetworkType> networks = ravencoinNetworks}) {
    final _keyPair = ECPair.fromWIF(wif, networks: networks);
    final _p2pkh = new P2PKH(
        data: new PaymentData(pubkey: _keyPair.publicKey),
        network: _keyPair.network);
    return Wallet(_keyPair, _p2pkh, _keyPair.network);
  }

  Uint8List sign(String message) {
    Uint8List messageHash = magicHash(message, network);
    return _keyPair.sign(messageHash);
  }

  bool verify({required String message, required Uint8List signature}) {
    Uint8List messageHash = magicHash(message, network);
    return _keyPair.verify(messageHash, signature);
  }
}
