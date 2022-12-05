import 'package:hive/hive.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/models/networks.dart'
    show NetworkType, mainnet, testnet, evrmoreMainnet, evrmoreTestnet;
import 'package:ravencoin_back/records/types/net.dart';
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

class ChainNet {
  ChainNet(this.chain, this.net);

  final Chain chain;
  final Net net;

  String get domainPortOf => '$domainOf:$portOf';

  /// moontree.com
  String get domainOf => 'moontree.com';

  /// port map
  ///50001 - mainnet tcp rvn
  ///50002 - mainnet ssl rvn
  ///50011 - testnet tcp rvnt
  ///50012 - testnet ssl rvnt
  ///50021 - mainnet tcp evr
  ///50022 - mainnet ssl evr
  ///50031 - testnet tcp evr
  ///50032 - testnet ssl evr
  int get portOf {
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

  NetworkType networkOf(Chain chain, Net net) {
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
}
