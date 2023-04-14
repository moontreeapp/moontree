import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'tutorial_status.g.dart';

@HiveType(typeId: TypeId.TutorialStatus)
enum TutorialStatus {
  @HiveField(0)
  blockchain,
  @HiveField(1)
  wallet,
}
