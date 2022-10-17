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

  String get id => Setting.key(name);

  static String key(SettingName name) => name.name;

  Type? get type => {
        SettingName.version_database: int,
        SettingName.login_attempts: List, //<DateTime>
        SettingName.electrum_net: Net,
        SettingName.electrum_domain: String,
        SettingName.electrum_port: int,
        SettingName.auth_method: AuthMethod,
        SettingName.blockchain: Chain,
        SettingName.wallet_current: String,
        SettingName.wallet_preferred: String,
        SettingName.local_path: String,
        SettingName.user_name: String, //?
        SettingName.send_immediate: bool,
        SettingName.version_previous: String, //?
        SettingName.version_current: String, //?
        SettingName.mode_dev: FeatureLevel,
      }[name];
}
