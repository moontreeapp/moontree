import 'dart:typed_data';
import 'dart:math';
import 'package:bip32/src/utils/ecurve.dart' as ecc;
import 'package:bip32/src/utils/wif.dart' as wif;
import 'models/networks.dart';

class ECPair {
  Uint8List? _d;
  Uint8List? _Q;
  NetworkType network;
  bool compressed;
  ECPair(Uint8List? this._d, Uint8List? this._Q,
      {this.network = mainnet, this.compressed = true});
  Uint8List? get publicKey {
    if (_Q == null) _Q = ecc.pointFromScalar(_d!, compressed);
    return _Q;
  }

  Uint8List? get privateKey => _d;
  String toWIF() {
    if (privateKey == null) {
      throw new ArgumentError('Missing private key');
    }
    return wif.encode(new wif.WIF(
        version: network.wif, privateKey: privateKey!, compressed: compressed));
  }

  Uint8List sign(Uint8List hash) {
    return ecc.sign(hash, privateKey!);
  }

  bool verify(Uint8List hash, Uint8List signature) {
    return ecc.verify(hash, publicKey!, signature);
  }

  factory ECPair.fromWIF(String w, NetworkType network) {
    wif.WIF decoded = wif.decode(w);
    if (decoded.version == network.wif) {
      return ECPair.fromPrivateKey(decoded.privateKey,
          compressed: decoded.compressed, network: network);
    } else {
      throw new ArgumentError('Incorrect network version');
    }
  }
  factory ECPair.fromPublicKey(Uint8List publicKey,
      {NetworkType network = mainnet, bool compressed = true}) {
    if (!ecc.isPoint(publicKey)) {
      throw new ArgumentError('Point is not on the curve');
    }
    return new ECPair(null, publicKey,
        network: network, compressed: compressed);
  }
  factory ECPair.fromPrivateKey(Uint8List privateKey,
      {NetworkType network = mainnet, bool compressed = true}) {
    if (privateKey.length != 32)
      throw new ArgumentError(
          'Expected property privateKey of type Buffer(Length: 32)');
    if (!ecc.isPrivate(privateKey))
      throw new ArgumentError('Private key not in range [1, n)');
    return new ECPair(privateKey, null,
        network: network, compressed: compressed);
  }
  factory ECPair.makeRandom(
      {NetworkType network = mainnet, bool compressed = true, Function? rng}) {
    final rfunc = rng ?? _randomBytes;
    Uint8List? d;
    do {
      d = rfunc(32);
      if (d!.length != 32) throw ArgumentError('Expected Buffer(Length: 32)');
    } while (!ecc.isPrivate(d));
    return ECPair.fromPrivateKey(d, network: network, compressed: compressed);
  }
}

const int _SIZE_BYTE = 255;
Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(_SIZE_BYTE);
  }
  return bytes;
}
