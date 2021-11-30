import 'dart:typed_data';

import 'package:hex/hex.dart';

import '../models/networks.dart';
import '../payments/index.dart' show PaymentData;
import '../payments/p2pkh.dart';
import '../ecpair.dart';
import '../utils/magic_hash.dart';

import 'wallet_base.dart';

class KPWallet extends WalletBase {
  ECPair _keyPair;

  @override
  String? get privKey => HEX.encode(_keyPair.privateKey!);

  @override
  String? get pubKey => HEX.encode(_keyPair.publicKey!);

  @override
  String? get wif => _keyPair.toWIF();

  KPWallet(this._keyPair, p2pkh, network) : super(p2pkh, network);

  factory KPWallet.random([NetworkType network = mainnet]) {
    final _keyPair = ECPair.makeRandom(network: network);
    final _p2pkh = new P2PKH(
        data: new PaymentData(pubkey: _keyPair.publicKey), network: network);
    return KPWallet(_keyPair, _p2pkh, network);
  }

  factory KPWallet.fromWIF(String wif,
      {Map<int, NetworkType> networks = networks}) {
    final _keyPair = ECPair.fromWIF(wif, networks: networks);
    final _p2pkh = new P2PKH(
        data: new PaymentData(pubkey: _keyPair.publicKey),
        network: _keyPair.network);
    return KPWallet(_keyPair, _p2pkh, _keyPair.network);
  }

  @override
  Uint8List sign(String message) {
    Uint8List messageHash = magicHash(message, network);
    return _keyPair.sign(messageHash);
  }

  @override
  bool verify({required String message, required Uint8List signature}) {
    Uint8List messageHash = magicHash(message, network);
    return _keyPair.verify(messageHash, signature);
  }
}
