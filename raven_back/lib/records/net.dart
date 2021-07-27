import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';

part 'net.g.dart';

var networks = {Net.Test: testnet, Net.Main: ravencoin};

@HiveType(typeId: 3)
enum Net {
  @HiveField(0)
  Main,

  @HiveField(1)
  Test
}
