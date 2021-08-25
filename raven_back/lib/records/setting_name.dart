import 'package:hive/hive.dart';
import 'package:raven/utils/enum.dart';

import '_type_id.dart';

part 'setting_name.g.dart';

/// Namespace_SettingName

@HiveType(typeId: TypeId.SettingName)
enum SettingName {
  @HiveField(0)
  Electrum_Url,

  @HiveField(1)
  Electrum_Port,

  @HiveField(2)
  Current_Account
}

extension EndingToString on SettingName {
  String endingToString() {
    return describeEnum(this);
  }
}
