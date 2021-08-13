import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';

import '_type_id.dart';

part 'net.g.dart';

var networks = {
  Net.Main: mainnet,
  Net.Test: testnet,
};

@HiveType(typeId: TypeId.Net)
enum Net {
  @HiveField(0)
  Main,

  @HiveField(1)
  Test
}
