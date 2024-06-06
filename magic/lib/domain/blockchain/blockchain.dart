import 'dart:typed_data';
import 'package:magic/domain/blockchain/chain.dart';
import 'package:magic/domain/blockchain/net.dart';
import 'package:moontree_utils/moontree_utils.dart';
// ignore: implementation_imports
import 'package:wallet_utils/src/models/networks.dart'
    show NetworkType, mainnet, testnet, evrmoreMainnet, evrmoreTestnet;

enum Blockchain {
  ravencoinMain,
  ravencoinTest,
  evrmoreMain,
  evrmoreTest,
  none;

  factory Blockchain.from({Chaindata? chaindata, String? name}) {
    switch (chaindata?.name ?? name) {
      case 'ravencoin_mainnet':
        return Blockchain.ravencoinMain;
      case 'ravencoin_testnet':
        return Blockchain.ravencoinTest;
      case 'evrmore_mainnet':
        return Blockchain.evrmoreMain;
      case 'evrmore_testnet':
        return Blockchain.evrmoreTest;
    }
    return Blockchain.none;
  }

  String explorerTxUrl(String txid) {
    switch (this) {
      case Blockchain.ravencoinMain:
        return 'https://rvn.cryptoscope.io/tx/?txid=$txid';
      case Blockchain.ravencoinTest:
        return 'https://rvnt.cryptoscope.io/tx/?txid=$txid';
      case Blockchain.evrmoreMain:
        return 'https://evr.cryptoscope.io/tx/?txid=$txid';
      case Blockchain.evrmoreTest:
        return 'https://evrt.cryptoscope.io/tx/?txid=$txid';
      case Blockchain.none:
        return '';
    }
  }

  Chain get chain {
    switch (this) {
      case Blockchain.ravencoinMain:
        return Chain.ravencoin;
      case Blockchain.ravencoinTest:
        return Chain.ravencoin;
      case Blockchain.evrmoreMain:
        return Chain.evrmore;
      case Blockchain.evrmoreTest:
        return Chain.evrmore;
      case Blockchain.none:
        return Chain.none;
    }
  }

  Net get net {
    switch (this) {
      case Blockchain.ravencoinMain:
        return Net.main;
      case Blockchain.ravencoinTest:
        return Net.test;
      case Blockchain.evrmoreMain:
        return Net.main;
      case Blockchain.evrmoreTest:
        return Net.test;
      case Blockchain.none:
        return Net.test;
    }
  }

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
