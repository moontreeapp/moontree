// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/client_back.dart';

import '_type_id.dart';
part 'setting.g.dart';

@HiveType(typeId: TypeId.Setting)
class Setting with EquatableMixin {
  const Setting({
    required this.name,
    required this.value,
  });

  factory Setting.from(
    Setting setting, {
    SettingName? name,
    dynamic value,
    bool valueIsNull = false,
  }) =>
      Setting(
        name: name ?? setting.name,
        value: valueIsNull ? null : value ?? setting.value,
      );

  @HiveField(0)
  final SettingName name;

  @HiveField(1)
  final dynamic value;

  @override
  List<Object?> get props => <Object?>[name, value];

  @override
  String toString() => 'Setting($name, $value)';

  String get id => Setting.key(name);

  static String key(SettingName name) => name.name;

  Type? get type => <SettingName, Type>{
        SettingName.version_database: int,
        SettingName.login_attempts: List, //<DateTime>
        SettingName.blockchain_net: Net,
        SettingName.electrum_domain: String,
        SettingName.electrum_port: int,
        SettingName.auth_method: AuthMethod,
        SettingName.blockchain: Chain,
        SettingName.wallet_current: String,
        SettingName.wallet_preferred: String,
        SettingName.local_path: String,
        SettingName.user_name: String, //?
        SettingName.hide_fees: bool,
        SettingName.version_previous: String, //?
        SettingName.version_current: String, //?
        SettingName.mode_dev: FeatureLevel,
      }[name];
}
