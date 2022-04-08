import 'package:hive/hive.dart';

import '_type_id.dart';

part 'status_type.g.dart';

@HiveType(typeId: TypeId.StatusType)
enum StatusType {
  @HiveField(0)
  address,

  @HiveField(1)
  asset,

  @HiveField(2)
  header,
}
