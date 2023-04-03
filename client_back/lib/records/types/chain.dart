import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/models/networks.dart'
    show NetworkType, mainnet, testnet, evrmoreMainnet, evrmoreTestnet;
import 'package:client_back/records/types/net.dart';
import '../_type_id.dart';

part 'chain.g.dart';

//var chains = {
//  Chain.ravencoin: ravencoin,
//  Chain.evrmore: evrmore,
//};

@HiveType(typeId: TypeId.Chain)
enum Chain {
  @HiveField(0)
  none,

  @HiveField(1)
  evrmore,

  @HiveField(2)
  ravencoin,
}

extension ChainExtension on Chain {
  String get symbol {
    switch (this) {
      case Chain.ravencoin:
        return 'RVN';
      case Chain.evrmore:
        return 'EVR';
      case Chain.none:
        return '';
    }
  }

  String get title => name.toTitleCase();
  String get key => name;
  String get readable => 'chain: $name';
  static Chain from(String s) {
    s = s.toLowerCase();
    if (s.toLowerCase().startsWith('r')) {
      return Chain.ravencoin;
    } else if (s.toLowerCase().startsWith('e')) {
      return Chain.evrmore;
    } else {
      return Chain.none;
    }
  }
}

String symbolName(String symbol) {
  switch (symbol) {
    case 'RVN':
      return 'Ravencoin';
    case 'EVR':
      return 'Evrmore';
    case 'RVNt':
      return 'Ravencoin (testnet)';
    case 'EVRt':
      return 'Evrmore (testnet)';
    default:
      return symbol;
  }
}

String nameSymbol(String name) {
  switch (name) {
    case 'Ravencoin':
      return 'RVN';
    case 'Evrmore':
      return 'EVR';
    case 'Ravencoin (testnet)':
      return 'RVN'; // the symbol on testnet is still the coin
    case 'Evrmore (testnet)':
      return 'EVR'; // the symbol on testnet is still the coin
    default:
      return name;
  }
}

class ChainNet with EquatableMixin {
  final Chain chain;
  final Net net;

  const ChainNet(this.chain, this.net);

  factory ChainNet.from({Chaindata? chaindata, String? name}) {
    switch (chaindata?.name ?? name) {
      case 'ravencoin_mainnet':
        return ChainNet(Chain.ravencoin, Net.main);
      case 'ravencoin_testnet':
        return ChainNet(Chain.ravencoin, Net.test);
      case 'evrmore_mainnet':
        return ChainNet(Chain.evrmore, Net.main);
      case 'evrmore_testnet':
        return ChainNet(Chain.evrmore, Net.test);
    }
    return ChainNet(Chain.ravencoin, Net.main);
  }

  @override
  List<Object?> get props => <Object?>[chain, net];

  @override
  String toString() => props.toString();

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

  String get readable => '${chain.readable}, ${net.readable}';

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

  String get key => '${chain.key}:${net.key}';

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
}
