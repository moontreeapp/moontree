import 'package:raven/box_adapters.dart';
import 'package:ravencoin/ravencoin.dart';
import 'network_params.dart';

final ravencoinMainnet = NetworkParams(
    name: 'Ravencoin Mainnet',
    testnet: false,
    network: ravencoin,
    derivationBase: "m/44'/175'/0'");

final ravencoinTestnet = NetworkParams(
    name: 'Ravencoin Testnet',
    testnet: true,
    network: testnet,
    derivationBase: "m/44'/175'/1'");
