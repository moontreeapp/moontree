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

  /// mainnet or testnet
  @HiveField(2)
  blockchain_net,

  /// electrum domain
  @HiveField(3)
  electrum_domain,

  /// electrum port
  @HiveField(4)
  electrum_port,

  /// which kind of authentication the user has chosen - password or native
  @HiveField(5)
  auth_method,

  /// which blockchain the user is looking at.
  @HiveField(6)
  blockchain,

  /// which wallet the user is looking at.
  @HiveField(7)
  wallet_current,

  /// ignored - the wallet we should open the app with. this is always the
  /// wallet_current.
  @HiveField(8)
  wallet_preferred,

  /// on startup we save local path to this setting since it doesn't change and
  /// we don't want to await getting it in build functions. in the future the
  /// user could possibly specify where they want exports or other files to be
  /// saved using this setting.
  @HiveField(9)
  local_path,

  /// unused in the future we anticipate users can associate, if they so choose,
  /// a wallet with their name or some chosen name and thereby allow others to
  /// send to them by that name when using moontree.
  @HiveField(10)
  user_name,

  /// if you send value to yourself, or transfer an asset a transaction fee
  /// entry shows up in the list of transactions. if you do a lot of asset
  /// transfers your transaction history for the base coin will fill up with
  /// transaction fee entries because transaction fees are paid in the base coin
  /// you can hide these fees with this setting.
  @HiveField(11)
  hide_fees,

  @HiveField(12)
  version_previous,

  @HiveField(13)
  version_current,

  @HiveField(14)
  mode_dev,

  @HiveField(15)
  tutorial_status,

  @HiveField(16)
  hidden_assets,

  @HiveField(17)
  full_assets,
}
