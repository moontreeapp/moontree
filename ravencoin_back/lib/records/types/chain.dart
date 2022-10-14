import 'package:hive/hive.dart';
import 'package:ravencoin_back/extensions/string.dart';
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

String chainName(Chain chain) => chain.name.toTitleCase();

String chainNetSymbol(Chain chain, Net net) =>
    chainSymbol(chain) + netSymbolModifier(net);

String chainKey(Chain chain) => chain.name;

String chainNetKey(Chain chain, Net net) => chainKey(chain) + ':' + netKey(net);

String chainReadable(Chain chain) => 'chain: ${chain.name}';
String chainNetReadable(Chain chain, Net net) =>
    '${chainReadable(chain)}, ${netReadable(net)}';
