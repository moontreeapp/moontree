import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/records/records.dart';
import 'package:wallet_utils/wallet_utils.dart' show NetworkType;

part 'setting.keys.dart';

class SettingProclaim extends Proclaim<_IdKey, Setting> {
  SettingProclaim() : super(_IdKey());

  static final Net defaultNet = Net.main;
  static final Chain defaultChain = Chain.ravencoin;
  static final String defaultDomain = domainOf(defaultChain, defaultNet);
  static final int defaultPort = portOf(defaultChain, defaultNet);
  static final List<TutorialStatus> tutorials = const [
    TutorialStatus.blockchain
  ];

  static Map<String, Setting> get defaults => {
        SettingName.version_database:
            Setting(name: SettingName.version_database, value: 1),
        SettingName.login_attempts:
            Setting(name: SettingName.login_attempts, value: <DateTime>[]),
        SettingName.electrum_net:
            Setting(name: SettingName.electrum_net, value: defaultNet),
        SettingName.electrum_domain:
            Setting(name: SettingName.electrum_domain, value: defaultDomain),
        SettingName.electrum_port:
            Setting(name: SettingName.electrum_port, value: defaultPort),
        SettingName.auth_method: Setting(
            name: SettingName.auth_method, value: AuthMethod.nativeSecurity),
        SettingName.blockchain:
            Setting(name: SettingName.blockchain, value: Chain.ravencoin),
        SettingName.wallet_current:
            Setting(name: SettingName.wallet_current, value: '0'),
        SettingName.wallet_preferred:
            Setting(name: SettingName.wallet_preferred, value: '0'),
        SettingName.user_name:
            Setting(name: SettingName.user_name, value: null),
        SettingName.send_immediate:
            Setting(name: SettingName.send_immediate, value: false),
        SettingName.version_current:
            Setting(name: SettingName.send_immediate, value: null),
        SettingName.version_previous:
            Setting(name: SettingName.send_immediate, value: null),
        SettingName.mode_dev:
            Setting(name: SettingName.mode_dev, value: FeatureLevel.easy),
        SettingName.tutorial_status: Setting(
            name: SettingName.tutorial_status, value: <TutorialStatus>[]),
      }.map((settingName, setting) => MapEntry(settingName.name, setting));

  /// should this be in the database or should it be a constant somewhere?
  //int get appVersion =>
  //    primaryIndex.getOne(SettingName.app_version)!.value;

  int get databaseVersion =>
      primaryIndex.getOne(SettingName.version_database)!.value;

  String get preferredWalletId =>
      primaryIndex.getOne(SettingName.wallet_preferred)!.value;

  String get currentWalletId =>
      primaryIndex.getOne(SettingName.wallet_current)!.value;

  String? get localPath => primaryIndex.getOne(SettingName.local_path)?.value;

  String get domainPort =>
      '${primaryIndex.getOne(SettingName.electrum_domain)?.value}:${primaryIndex.getOne(SettingName.electrum_port)?.value}';

  String get domainPortOfChainNet => domainPortOf(chain, net);

  String get defaultDomainPort => '$defaultDomain:$defaultPort';

  Future restoreDomainPort() async => saveAll([
        Setting(name: SettingName.electrum_domain, value: defaultDomain),
        Setting(name: SettingName.electrum_port, value: defaultPort),
      ]);

  Future savePreferredWalletId(String walletId) async =>
      await save(Setting(name: SettingName.wallet_preferred, value: walletId));

  Future setCurrentWalletId([String? walletId]) async => save(Setting(
      name: SettingName.wallet_current, value: walletId ?? preferredWalletId));

  Net get net => primaryIndex.getOne(SettingName.electrum_net)!.value;

  bool get mainnet =>
      primaryIndex.getOne(SettingName.electrum_net)!.value == Net.main;

  NetworkType get network => networkOf(chain, net);

  String get netName => net.name;

  List get loginAttempts =>
      primaryIndex.getOne(SettingName.login_attempts)!.value;

  Future saveLoginAttempts(List attempts) async =>
      await save(Setting(name: SettingName.login_attempts, value: attempts));

  Future incrementLoginAttempts() async =>
      await saveLoginAttempts(loginAttempts + <DateTime>[DateTime.now()]);

  Future resetLoginAttempts() async => saveLoginAttempts([]);

  Chain get chain => primaryIndex.getOne(SettingName.blockchain)!.value;

  Future setBlockchain({
    Chain chain = Chain.ravencoin,
    Net net = Net.main,
  }) async {
    await saveAll([
      Setting(name: SettingName.electrum_net, value: net),
      Setting(name: SettingName.blockchain, value: chain)
    ]);
    await setDomainPortForChainNet();
  }

  Future setDomainPortForChainNet() async {
    /// triggers should be set to change the domain:port by chain:net
    /// for now we'll put it here:
    await saveAll([
      Setting(name: SettingName.electrum_port, value: portOf(chain, net)),
      Setting(name: SettingName.electrum_domain, value: domainOf(chain, net)),
    ]);
  }

  AuthMethod? get authMethod =>
      primaryIndex.getOne(SettingName.auth_method)?.value;

  bool get authMethodIsNativeSecurity =>
      primaryIndex.getOne(SettingName.auth_method)!.value ==
      AuthMethod.nativeSecurity;
}
