import 'package:hive/hive.dart';

import '_type_id.dart';

part 'setting_name.g.dart';

/// Namespace_SettingName

@HiveType(typeId: TypeId.SettingName)
enum SettingName {
  @HiveField(0)
  Database_Version,

  @HiveField(1)
  Login_Attempts,

  @HiveField(2)
  Electrum_Net,

  @HiveField(3)
  Electrum_Domain,

  @HiveField(4)
  Electrum_Port,

  @HiveField(5)
  Electrum_DomainTest,

  @HiveField(6)
  Electrum_PortTest,

  @HiveField(7)
  Wallet_Current,

  @HiveField(8)
  Wallet_Preferred,

  @HiveField(9)
  Local_Path,

  @HiveField(10)
  User_Name,

  @HiveField(11)
  Send_Immediate,
}
