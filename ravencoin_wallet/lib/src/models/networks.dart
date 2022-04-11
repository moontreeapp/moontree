class NetworkType {
  final String messagePrefix;
  final String? bech32;
  final Bip32Type bip32;
  final int pubKeyHash;
  final int scriptHash;
  final int wif;
  final String derivationAccountPath;
  final BurnAddress burnAddresses;
  final BurnAmount burnAmounts;

  const NetworkType(
      {required this.messagePrefix,
      this.bech32,
      required this.bip32,
      required this.pubKeyHash,
      required this.scriptHash,
      required this.wif,
      required this.derivationAccountPath,
      required this.burnAddresses,
      required this.burnAmounts});

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

class BurnAddress {
  final String issueMain;
  final String reissue;
  final String issueSub;
  final String issueUnique;
  final String issueMessage;
  final String issueQualifier;
  final String issueSubQualifier;
  final String issueRestricted;
  final String addTag;
  final String burn;

  const BurnAddress(
      {required this.issueMain,
      required this.reissue,
      required this.issueSub,
      required this.issueUnique,
      required this.issueMessage,
      required this.issueQualifier,
      required this.issueSubQualifier,
      required this.issueRestricted,
      required this.addTag,
      required this.burn});

  static const DUMMY = BurnAddress(
      issueMain: '',
      reissue: '',
      issueSub: '',
      issueUnique: '',
      issueMessage: '',
      issueQualifier: '',
      issueSubQualifier: '',
      issueRestricted: '',
      addTag: '',
      burn: '');
}

class BurnAmount {
  // In satoshis
  final int issueMain;
  final int reissue;
  final int issueSub;
  final int issueUnique;
  final int issueMessage;
  final int issueQualifier;
  final int issueSubQualifier;
  final int issueRestricted;
  final int addTag;

  const BurnAmount(
      {required this.issueMain,
      required this.reissue,
      required this.issueSub,
      required this.issueUnique,
      required this.issueMessage,
      required this.issueQualifier,
      required this.issueSubQualifier,
      required this.issueRestricted,
      required this.addTag});

  static const DUMMY = BurnAmount(
      issueMain: 0,
      reissue: 0,
      issueSub: 0,
      issueUnique: 0,
      issueMessage: 0,
      issueQualifier: 0,
      issueSubQualifier: 0,
      issueRestricted: 0,
      addTag: 0);
}

// Ravencoin Mainnet
const mainnet = NetworkType(
    messagePrefix: '\x16Raven Signed Message:\n',
    bech32: 'rc',
    bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x3c,
    scriptHash: 0x7a,
    wif: 0x80,
    derivationAccountPath: "m/44'/175'/0'",
    burnAddresses: BurnAddress(
        issueMain: 'RXissueAssetXXXXXXXXXXXXXXXXXhhZGt',
        reissue: 'RXReissueAssetXXXXXXXXXXXXXXVEFAWu',
        issueSub: 'RXissueSubAssetXXXXXXXXXXXXXWcwhwL',
        issueUnique: 'RXissueUniqueAssetXXXXXXXXXXWEAe58',
        issueMessage: 'RXissueMsgChanneLAssetXXXXXXSjHvAY',
        issueQualifier: 'RXissueQuaLifierXXXXXXXXXXXXUgEDbC',
        issueSubQualifier: 'RXissueSubQuaLifierXXXXXXXXXVTzvv5',
        issueRestricted: 'RXissueRestrictedXXXXXXXXXXXXzJZ1q',
        addTag: 'RXaddTagBurnXXXXXXXXXXXXXXXXZQm5ya',
        burn: 'RXBurnXXXXXXXXXXXXXXXXXXXXXXWUo9FV'),
    burnAmounts: BurnAmount(
        issueMain: 50000000000,
        reissue: 10000000000,
        issueSub: 10000000000,
        issueUnique: 500000000,
        issueMessage: 10000000000,
        issueQualifier: 100000000000,
        issueSubQualifier: 10000000000,
        issueRestricted: 150000000000,
        addTag: 10000000));

// Ravencoin Testnet
const testnet = NetworkType(
    messagePrefix: '\x16Raven Signed Message:\n',
    bech32: 'tr',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
    derivationAccountPath: "m/44'/1'/0'",
    burnAddresses: BurnAddress(
        issueMain: 'n1issueAssetXXXXXXXXXXXXXXXXWdnemQ',
        reissue: 'n1ReissueAssetXXXXXXXXXXXXXXWG9NLd',
        issueSub: 'n1issueSubAssetXXXXXXXXXXXXXbNiH6v',
        issueUnique: 'n1issueUniqueAssetXXXXXXXXXXS4695i',
        issueMessage: 'n1issueMsgChanneLAssetXXXXXXT2PBdD',
        issueQualifier: 'n1issueQuaLifierXXXXXXXXXXXXUysLTj',
        issueSubQualifier: 'n1issueSubQuaLifierXXXXXXXXXYffPLh',
        issueRestricted: 'n1issueRestrictedXXXXXXXXXXXXZVT9V',
        addTag: 'n1addTagBurnXXXXXXXXXXXXXXXXX5oLMH',
        burn: 'n1BurnXXXXXXXXXXXXXXXXXXXXXXU1qejP'),
    burnAmounts: BurnAmount(
        issueMain: 50000000000,
        reissue: 10000000000,
        issueSub: 10000000000,
        issueUnique: 500000000,
        issueMessage: 10000000000,
        issueQualifier: 100000000000,
        issueSubQualifier: 10000000000,
        issueRestricted: 150000000000,
        addTag: 10000000));

const networks = {0x80: mainnet, 0xef: testnet};

// Used for some legacy tests
const bitcoinMainnet = NetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'bc',
    bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
    pubKeyHash: 0x00,
    scriptHash: 0x05,
    wif: 0x80,
    derivationAccountPath: "m/44'/1'/0'",
    burnAddresses: BurnAddress.DUMMY,
    burnAmounts: BurnAmount.DUMMY);

const bitcoinTestnet = NetworkType(
    messagePrefix: '\x18Bitcoin Signed Message:\n',
    bech32: 'tb',
    bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
    pubKeyHash: 0x6f,
    scriptHash: 0xc4,
    wif: 0xef,
    derivationAccountPath: "m/44'/1'/0'",
    burnAddresses: BurnAddress.DUMMY,
    burnAmounts: BurnAmount.DUMMY);

const bitcoinNetworks = {0x80: bitcoinMainnet, 0xef: bitcoinTestnet};
