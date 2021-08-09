import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';

part 'net.g.dart';

var networks = {
  Net.Main: mainnet,
  Net.Test: testnet,
};

@HiveType(typeId: 6)
enum Net {
  @HiveField(0)
  Main,

  @HiveField(1)
  Test
}
