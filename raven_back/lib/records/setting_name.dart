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
  Electrum_DomainTest,

  @HiveField(7)
  Electrum_PortTest,

  @HiveField(8)
  Electrum_Net,

  @HiveField(9)
  Account_Current,

  @HiveField(10)
  Account_Preferred,

  @HiveField(11)
  Local_Path,

  @HiveField(12)
  User_Name,

  @HiveField(13)
  Send_Immediate, // no confirmation screen, no generating transaction screen, just does it in background
}
