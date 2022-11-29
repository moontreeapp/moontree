import 'package:hive/hive.dart';
import 'package:ravencoin_back/extensions/string.dart';
import 'package:ravencoin_back/records/types/net.dart';
import 'package:wallet_utils/src/models/networks.dart'
    show NetworkType, mainnet, testnet, evrmoreMainnet, evrmoreTestnet;
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

String chainSymbol(Chain chain) {
  switch (chain) {
    case Chain.ravencoin:
      return 'RVN';
    case Chain.evrmore:
      return 'EVR';
    case Chain.none:
      return '';
    default:
      return 'RVN';
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

String chainName(Chain chain) => chain.name.toTitleCase();

String chainNetSymbol(Chain chain, Net net) =>
    chainSymbol(chain) + netSymbolModifier(net);

String chainKey(Chain chain) => chain.name;

String chainNetKey(Chain chain, Net net) => chainKey(chain) + ':' + netKey(net);

String chainReadable(Chain chain) => 'chain: ${chain.name}';
String chainNetReadable(Chain chain, Net net) =>
    '${chainReadable(chain)}, ${netReadable(net)}';

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

/// moontree.com
String domainOf(Chain chain, Net net) => 'moontree.com';

/// port map
///50001 - mainnet tcp rvn
///50002 - mainnet ssl rvn
///50011 - testnet tcp rvnt
///50012 - testnet ssl rvnt
///50021 - mainnet tcp evr
///50022 - mainnet ssl evr
///50031 - testnet tcp evr
///50032 - testnet ssl evr
int portOf(Chain chain, Net net) {
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

String domainPortOf(Chain chain, Net net) =>
    '${domainOf(chain, net)}:${portOf(chain, net)}';
