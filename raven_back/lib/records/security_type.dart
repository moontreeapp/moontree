import 'package:hive/hive.dart';

part 'security_type.g.dart';

@HiveType(typeId: 9)
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
