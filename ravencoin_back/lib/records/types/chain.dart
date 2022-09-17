import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'chain.g.dart';

//var chains = {
//  Chain.ravencoin: ravencoin,
//  Chain.evrmore: evrmore,
//};

@HiveType(typeId: TypeId.Chain)
enum Chain {
  @HiveField(0)
  ravencoin,

  @HiveField(1)
  evrmore,
}
