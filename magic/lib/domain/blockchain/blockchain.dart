import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:magic/domain/blockchain/chain.dart';
import 'package:magic/domain/blockchain/net.dart';
import 'package:moontree_utils/moontree_utils.dart';
// ignore: implementation_imports
import 'package:wallet_utils/src/models/networks.dart'
    show NetworkType, mainnet, testnet, evrmoreMainnet, evrmoreTestnet;

class Blockchain with EquatableMixin {
  final Chain chain;
  final Net net;

  const Blockchain(this.chain, this.net);

  factory Blockchain.from({Chaindata? chaindata, String? name}) {
    switch (chaindata?.name ?? name) {
      case 'ravencoin_mainnet':
        return const Blockchain(Chain.ravencoin, Net.main);
      case 'ravencoin_testnet':
        return const Blockchain(Chain.ravencoin, Net.test);
      case 'evrmore_mainnet':
        return const Blockchain(Chain.evrmore, Net.main);
      case 'evrmore_testnet':
        return const Blockchain(Chain.evrmore, Net.test);
    }
    return const Blockchain(Chain.ravencoin, Net.main);
  }

  @override
  List<Object?> get props => <Object?>[chain, net];

  @override
  String toString() => props.toString();

  int get purpose => 44;
  int get coinType {
    if (chain == Chain.ravencoin || chain == Chain.evrmore) {
      if (net == Net.main) {
        return 175;
      } else if (net == Net.test) {
        return 1;
      }
    }
    return 0;
  }

  String get domainPort => '$domain:$port';

  /// moontree.com
  String get domain => 'moontree.com';

  /// port map
  ///50001 - mainnet tcp rvn
  ///50002 - mainnet ssl rvn
  ///50011 - testnet tcp rvnt
  ///50012 - testnet ssl rvnt
  ///50021 - mainnet tcp evr
  ///50022 - mainnet ssl evr
  ///50031 - testnet tcp evr
  ///50032 - testnet ssl evr
  int get port {
    if (chain == Chain.ravencoin && net == Net.main) {
      return 50002;
    }
    if (chain == Chain.ravencoin && net == Net.test) {
      return 50012;
    }
    if (chain == Chain.evrmore && net == Net.main) {
      return 50022;
    }
    if (chain == Chain.evrmore && net == Net.test) {
      return 50032;
    }
    return 50002;
  }

  NetworkType get network {
    if (chain == Chain.ravencoin && net == Net.main) {
      return mainnet;
    }
    if (chain == Chain.ravencoin && net == Net.test) {
      return testnet;
    }
    if (chain == Chain.evrmore && net == Net.main) {
      return evrmoreMainnet;
    }
    if (chain == Chain.evrmore && net == Net.test) {
      return evrmoreTestnet;
    }
    return mainnet;
  }

  String get symbol => chain.symbol + net.symbolModifier;

  Chaindata get chaindata {
    if (chain == Chain.ravencoin) {
      if (net == Net.main) {
        return ravencoinMainnetChaindata;
      } else if (net == Net.test) {
        return ravencoinTestnetChaindata;
      }
    } else if (chain == Chain.evrmore) {
      if (net == Net.main) {
        return evrmoreMainnetChaindata;
      } else if (net == Net.test) {
        return evrmoreTestnetChaindata;
      }
    }
    return ravencoinMainnetChaindata;
  }

  //Constants get constants =>
  //    net == Net.main ? mainnetConstants : testnetConstants;

  Constants get constants {
    final Chaindata cd = chaindata;
    return Constants(
        cd.kawpowHeaderActivationTimestamp, cd.p2pkhPrefix, cd.p2shPrefix);
  }

  String addressFromH160String(String h160, {bool isP2sh = false}) =>
      addressFromH160(h160.hexBytes, isP2sh: isP2sh);

  String addressFromH160(Uint8List h160, {bool isP2sh = false}) =>
      h160ToAddress(
          h160, isP2sh ? chaindata.p2shPrefix : chaindata.p2pkhPrefix);
}
