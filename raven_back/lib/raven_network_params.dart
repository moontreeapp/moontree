import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'wallet_exposure.dart';

class RavenNetworkParams {
  String name;
  bool testnet;
  NetworkType network;
  String derivationBase;

  RavenNetworkParams({
    required this.name,
    required this.testnet,
    required this.network,
    required this.derivationBase,
  });

  String derivationPath(int index, {exposure = WalletExposure.External}) {
    return '$derivationBase/${exposureToDerivationPathPart(exposure)}/$index';
  }

  @override
  String toString() {
    return 'RavenNetworkParams{name: $name, testnet: $testnet, network: ${network.toString()}, derivationPath: $derivationPath';
  }
}

final ravencoinMainnet = RavenNetworkParams(
    name: 'Ravencoin Mainnet',
    testnet: false,
    network: NetworkType(
        messagePrefix: '\x16Raven Signed Message:\n',
        bech32: 'rc',
        bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
        pubKeyHash: 0x3c,
        scriptHash: 0x7a,
        wif: 0x80),
    derivationBase: "m/44'/175'/0'");

final ravencoinTestnet = RavenNetworkParams(
    name: 'Ravencoin Testnet',
    testnet: true,
    network: NetworkType(
        messagePrefix: '\x16Raven Signed Message:\n',
        bech32: 'tr',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x6f,
        scriptHash: 0xc4,
        wif: 0xef),
    derivationBase: "m/44'/175'/1'");
