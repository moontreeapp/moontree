class NetworkType {
  final String messagePrefix;
  final String? bech32;
  final Bip32Type bip32;
  final int pubKeyHash;
  final int scriptHash;
  final int wif;

  const NetworkType(
      {required this.messagePrefix,
      this.bech32,
      required this.bip32,
      required this.pubKeyHash,
      required this.scriptHash,
      required this.wif});

  @override
  String toString() {
    return 'NetworkType{messagePrefix: $messagePrefix, bech32: $bech32, bip32: ${bip32.toString()}, pubKeyHash: $pubKeyHash, scriptHash: $scriptHash, wif: $wif}';
  }
}

class Bip32Type {
  final int public;
  final int private;

  const Bip32Type({required this.public, required this.private});

  @override
  String toString() {
    return 'Bip32Type{public: $public, private: $private}';
  }
}

// Ravencoin Mainnet
const ravencoin = NetworkType(
    messagePrefix: '\x16Raven Signed Message:\n',
    bech32: 'rc',
    bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x3c,
    scriptHash: 0x7a,
    wif: 0x80);

// Ravencoin Testnet
const testnet = NetworkType(
    messagePrefix: '\x16Raven Signed Message:\n',
    bech32: 'tr',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef);

const ravencoinNetworks = {0x80: ravencoin, 0xef: testnet};

// Used for some legacy tests
const bitcoin = NetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80);

const bitcoinTestnet = NetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef);

const bitcoinNetworks = {0x80: bitcoin, 0xef: bitcoinTestnet};
