// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/records/setting_name.dart';
import 'package:raven_back/extensions/object.dart';

import '_type_id.dart';
part 'setting.g.dart';

@HiveType(typeId: TypeId.Setting)
class Setting with EquatableMixin {
  @HiveField(0)
  SettingName name;

  @HiveField(1)
  dynamic value;

  Setting({
    required this.name,
    required this.value,
  });

  @override
  List<Object> get props => [name, value ?? ''];

  @override
  String toString() => 'Setting($name, $value)';

  String get settingId => Setting.settingKey(name);

  static String settingKey(SettingName name) => name.enumString;

  Type? get type => {
        SettingName.Electrum_Net: Net,
        SettingName.Electrum_Domain: String,
        SettingName.Electrum_Port: int,
        SettingName.Electrum_DomainTest: String,
        SettingName.Electrum_PortTest: int,
        SettingName.Wallet_Current: String,
        SettingName.Wallet_Preferred: String,
        SettingName.Local_Path: String,
        SettingName.User_Name: String,
        SettingName.Send_Immediate: bool,
      }[name];
}
