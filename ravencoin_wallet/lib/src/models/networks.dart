import 'package:meta/meta.dart';

class NetworkType {
  String messagePrefix;
  String bech32;
  Bip32Type bip32;
  int pubKeyHash;
  int scriptHash;
  int wif;

  NetworkType(
      {@required this.messagePrefix,
      this.bech32,
      @required this.bip32,
      @required this.pubKeyHash,
      @required this.scriptHash,
      @required this.wif});

  @override
  String toString() {
    return 'NetworkType{messagePrefix: $messagePrefix, bech32: $bech32, bip32: ${bip32.toString()}, pubKeyHash: $pubKeyHash, scriptHash: $scriptHash, wif: $wif}';
  }
}

class Bip32Type {
  int public;
  int private;

  Bip32Type({@required this.public, @required this.private});

  @override
  String toString() {
    return 'Bip32Type{public: $public, private: $private}';
  }
}

final ravencoin = NetworkType(
    messagePrefix: '\x16Raven Signed Message:\n',
    bech32: 'rc',
    bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x3c,
    scriptHash: 0x7a,
    wif: 0x80);

final testnet = NetworkType(
    messagePrefix: '\x16Raven Signed Message:\n',
    bech32: 'tr',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef);
