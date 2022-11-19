import 'package:hive/hive.dart';
import 'package:wallet_utils/wallet_utils.dart';

import '../_type_id.dart';

part 'net.g.dart';

@HiveType(typeId: TypeId.Net)
enum Net {
  @HiveField(0)
  main,

  @HiveField(1)
  test
}

String netSymbolModifier(Net net) {
  switch (net) {
    case Net.main:
      return '';
    case Net.test:
      return 't';
    default:
      return '';
  }
}

String netKey(Net net) => net.name;

String netReadable(Net net) => 'net: ${net.name}';

String netName(Net net) => net.name;
