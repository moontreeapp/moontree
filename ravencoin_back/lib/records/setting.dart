// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

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

  String get id => Setting.settingKey(name);

  static String settingKey(SettingName name) => name.name;

  Type? get type => {
        SettingName.Version_Database: int,
        SettingName.Login_Attempts: List, //<DateTime>
        SettingName.Electrum_Net: Net,
        SettingName.Electrum_Domain: String,
        SettingName.Electrum_Port: int,
        SettingName.Auth_Method: AuthMethod,
        SettingName.Blockchain: Chain,
        SettingName.Wallet_Current: String,
        SettingName.Wallet_Preferred: String,
        SettingName.Local_Path: String,
        SettingName.User_Name: String, //?
        SettingName.Send_Immediate: bool,
        SettingName.Version_Previous: String, //?
        SettingName.Version_Current: String, //?
        SettingName.Mode_Dev: bool,
      }[name];
}
