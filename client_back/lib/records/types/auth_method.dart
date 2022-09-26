import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'auth_method.g.dart';

@HiveType(typeId: TypeId.AuthMethod)
enum AuthMethod {
  @HiveField(0)
  moontreePassword,

  @HiveField(1)
  nativeSecurity,
}
