import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'feature_level.g.dart';

@HiveType(typeId: TypeId.FeatureLevel)
enum FeatureLevel {
  @HiveField(0)
  easy,

  @HiveField(1)
  normal,

  @HiveField(2)
  expert,
}
