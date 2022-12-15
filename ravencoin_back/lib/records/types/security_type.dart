import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'security_type.g.dart';

@HiveType(typeId: TypeId.SecurityType)
enum SecurityType {
  @HiveField(0)
  fiat,

  @HiveField(1)
  coin,

  @HiveField(2)
  asset,
}
