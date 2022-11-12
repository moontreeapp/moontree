import 'package:hive/hive.dart';

import '../_type_id.dart';

part 'setting_name.g.dart';

/// Namespace_SettingName

@HiveType(typeId: TypeId.SettingName)
enum SettingName {
  @HiveField(0)
  version_database, //database_version,

  @HiveField(1)
  login_attempts,

  @HiveField(2)
  electrum_net,

  @HiveField(3)
  electrum_domain,

  @HiveField(4)
  electrum_port,

  @HiveField(5)
  auth_method,

  @HiveField(6)
  blockchain,

  @HiveField(7)
  wallet_current,

  @HiveField(8)
  wallet_preferred,

  @HiveField(9)
  local_path,

  @HiveField(10)
  user_name,

  @HiveField(11)
  send_immediate,

  @HiveField(12)
  version_previous,

  @HiveField(13)
  version_current,

  @HiveField(14)
  mode_dev,
}
