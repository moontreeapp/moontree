import 'dart:typed_data';

import 'package:ravencoin/src/utils/magic_hash.dart';
import 'package:hex/hex.dart';
import 'package:bip32/bip32.dart' as bip32;

import '../models/networks.dart';
import '../payments/index.dart' show PaymentData;
import '../payments/p2pkh.dart';

import 'wallet_base.dart';

class HDWallet extends WalletBase {
  bip32.BIP32 _bip32;
  Uint8List? seed;

  @override
  String? get privKey {
    try {
      return HEX.encode(_bip32.privateKey!);
    } catch (_) {
      return null;
    }
  }

  @override
  String get pubKey => HEX.encode(_bip32.publicKey);

  String? get base58Priv {
    try {
      return _bip32.toBase58();
    } catch (_) {
      return null;
    }
  }

  String? get base58 => _bip32.neutered().toBase58();

  @override
  String? get wif {
    try {
      return _bip32.toWIF();
    } catch (_) {
      return null;
    }
  }

  String? get seedHex => seed != null ? HEX.encode(seed!) : null;

  HDWallet({required bip32, required p2pkh, required network, this.seed})
      : this._bip32 = bip32,
        super(p2pkh, network);

  HDWallet derivePath(String path) {
    final bip32 = _bip32.derivePath(path);
    final p2pkh = new P2PKH(
        data: new PaymentData(pubkey: bip32.publicKey), network: network);
    return HDWallet(bip32: bip32, p2pkh: p2pkh, network: network);
  }

  HDWallet derive(int index) {
    final bip32 = _bip32.derive(index);
    final p2pkh = new P2PKH(
        data: new PaymentData(pubkey: bip32.publicKey), network: network);
    return HDWallet(bip32: bip32, p2pkh: p2pkh, network: network);
  }

  factory HDWallet.fromSeed(Uint8List seed, {NetworkType? network}) {
    network = network ?? ravencoin;
    final wallet = bip32.BIP32.fromSeed(
        seed,
        bip32.NetworkType(
            bip32: bip32.Bip32Type(
                public: network.bip32.public, private: network.bip32.private),
            wif: network.wif));
    final p2pkh = new P2PKH(
        data: new PaymentData(pubkey: wallet.publicKey), network: network);
    return HDWallet(bip32: wallet, p2pkh: p2pkh, network: network, seed: seed);
  }

  factory HDWallet.fromBase58(String xpub, {NetworkType? network}) {
    network = network ?? ravencoin;
    final wallet = bip32.BIP32.fromBase58(
        xpub,
        bip32.NetworkType(
            bip32: bip32.Bip32Type(
                public: network.bip32.public, private: network.bip32.private),
            wif: network.wif));
    final p2pkh = new P2PKH(
        data: new PaymentData(pubkey: wallet.publicKey), network: network);
    return HDWallet(bip32: wallet, p2pkh: p2pkh, network: network, seed: null);
  }

  @override
  Uint8List sign(String message) {
    Uint8List messageHash = magicHash(message, network);
    return _bip32.sign(messageHash);
  }

  @override
  bool verify({required String message, required Uint8List signature}) {
    Uint8List messageHash = magicHash(message);
    return _bip32.verify(messageHash, signature);
  }
}
