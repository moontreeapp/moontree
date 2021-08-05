import 'package:hive/hive.dart';

part 'node_exposure.g.dart';

@HiveType(typeId: 7)
enum NodeExposure {
  @HiveField(0)
  Internal,

  @HiveField(1)
  External
}
