import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'node_exposure.g.dart';

@HiveType(typeId: TypeId.NodeExposure)
enum NodeExposure {
  @HiveField(0)
  internal,

  @HiveField(1)
  external
}
