import 'package:hive/hive.dart';

import '_type_id.dart';

part 'setting_name.g.dart';

/// Namespace_SettingName

@HiveType(typeId: TypeId.SettingName)
enum SettingName {
  @HiveField(0)
  Electrum_Domain0,

  @HiveField(1)
  Electrum_Port0,

  @HiveField(2)
  Electrum_Domain1,

  @HiveField(3)
  Electrum_Port1,

  @HiveField(4)
  Electrum_Domain2,

  @HiveField(5)
  Electrum_Port2,

  @HiveField(6)
  Account_Current,

  @HiveField(7)
  Account_Preferred,
}
