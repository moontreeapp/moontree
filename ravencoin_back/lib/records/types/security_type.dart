import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'security_type.g.dart';

@HiveType(typeId: TypeId.SecurityType)
enum SecurityType {
  @HiveField(0)
  Fiat,

  @HiveField(1)
  Crypto,

  @HiveField(2)
  RavenAsset,

  @HiveField(3)
  RavenMaster,
}
