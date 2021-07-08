import 'package:raven/network_params.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';

final ravencoinMainnet = NetworkParams(
    name: 'Ravencoin Mainnet',
    testnet: false,
    network: NetworkType(
        messagePrefix: '\x16Raven Signed Message:\n',
        bech32: 'rc',
        bip32: Bip32Type(public: 0x0488b21e, private: 0x0488ade4),
        pubKeyHash: 0x3c,
        scripthash: 0x7a,
        wif: 0x80),
    derivationBase: "m/44'/175'/0'");

late final ravencoinTestnet = NetworkParams(
    name: 'Ravencoin Testnet',
    testnet: true,
    network: NetworkType(
        messagePrefix: '\x16Raven Signed Message:\n',
        bech32: 'tr',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x6f,
        scripthash: 0xc4,
        wif: 0xef),
    derivationBase: "m/44'/175'/1'");
