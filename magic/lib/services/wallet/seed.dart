//import 'dart:typed_data';
//
//import 'package:wallet_utils/wallet_utils.dart' show HDWallet, KPWallet;
//
//import 'package:client_back/utilities/derivation_path.dart';
//import 'package:client_back/client_back.dart';
//
//class SeedWallet {
//  final Uint8List seed;
//  final ChainNet chainNet;
//  final Map<String, HDWallet> subwalletsByPath = {};
//
//  SeedWallet(this.seed, this.chainNet);
//
//  HDWallet get wallet => HDWallet.fromSeed(seed, network: chainNet.network);
//
//  HDWallet subwallet(
//    int hdIndex, {
//    NodeExposure exposure = NodeExposure.external,
//  }) {
//    final path = getDerivationPath(
//      index: hdIndex,
//      exposure: exposure,
//      net: chainNet.net,
//    );
//    print('p: $path');
//    subwalletsByPath[path] ??= wallet.derivePath(path);
//    return subwalletsByPath[path]!;
//  }
//}
//
//class SingleSelfWallet {
//  String wif;
//
//  SingleSelfWallet(this.wif);
//
//  KPWallet get wallet {
//    return KPWallet.fromWIF(wif, pros.settings.network);
//  }
//}
