import 'package:hive/hive.dart';

import '_type_id.dart';

part 'setting_name.g.dart';

/// Namespace_SettingName

@HiveType(typeId: TypeId.SettingName)
enum SettingName {
  @HiveField(0)
  Electrum_Net,

  @HiveField(1)
  Electrum_Domain,

  @HiveField(2)
  Electrum_Port,

  @HiveField(3)
  Electrum_DomainTest,

  @HiveField(4)
  Electrum_PortTest,

  @HiveField(5)
  Wallet_Current,

  @HiveField(6)
  Wallet_Preferred,

  @HiveField(7)
  Local_Path,

  @HiveField(8)
  User_Name,

  @HiveField(9)
  Send_Immediate,

  @HiveField(10)
  Login_Attempts,
}
