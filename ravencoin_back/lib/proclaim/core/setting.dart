import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:wallet_utils/wallet_utils.dart' show NetworkType;
import 'package:ravencoin_back/records/records.dart';

part 'setting.keys.dart';

class SettingProclaim extends Proclaim<_IdKey, Setting> {
  SettingProclaim() : super(_IdKey());

  static const Net defaultNet = Net.main;
  static const Chain defaultChain = Chain.ravencoin;
  static final ChainNet defaultChainNet = ChainNet(defaultChain, defaultNet);
  static final String defaultDomain = defaultChainNet.domain;
  static final int defaultPort = defaultChainNet.port;
  static const List<TutorialStatus> tutorials = <TutorialStatus>[
    TutorialStatus.blockchain
  ];

  static Map<String, Setting> get defaults => <SettingName, Setting>{
        SettingName.version_database:
            Setting(name: SettingName.version_database, value: 1),
        SettingName.login_attempts:
            Setting(name: SettingName.login_attempts, value: <DateTime>[]),
        SettingName.electrum_net:
            Setting(name: SettingName.electrum_net, value: defaultNet),
        SettingName.electrum_domain: Setting(
            name: SettingName.electrum_domain, value: defaultChainNet.domain),
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
      }.map((SettingName settingName, Setting setting) =>
          MapEntry<String, Setting>(settingName.name, setting));

  /// should this be in the database or should it be a constant somewhere?
  //int get appVersion =>
  //    primaryIndex.getOne(SettingName.app_version)!.value;

  int get databaseVersion =>
      primaryIndex.getOne(SettingName.version_database)!.value as int;

  String get preferredWalletId =>
      primaryIndex.getOne(SettingName.wallet_preferred)!.value as String;

  String get currentWalletId =>
      primaryIndex.getOne(SettingName.wallet_current)!.value as String;

  String? get localPath =>
      primaryIndex.getOne(SettingName.local_path)?.value as String?;

  String get domainPort =>
      '${primaryIndex.getOne(SettingName.electrum_domain)?.value}:${primaryIndex.getOne(SettingName.electrum_port)?.value}';

  Net get net => primaryIndex.getOne(SettingName.electrum_net)!.value as Net;

  Chain get chain =>
      primaryIndex.getOne(SettingName.blockchain)!.value as Chain;

  ChainNet get chainNet => ChainNet(chain, net);

  String get domainPortOfChainNet => chainNet.domainPort;

  String get defaultDomainPort => defaultChainNet.domainPort;

  Future<List<Change<dynamic>>> restoreDomainPort() async => saveAll(<Setting>[
        Setting(name: SettingName.electrum_domain, value: defaultDomain),
        Setting(name: SettingName.electrum_port, value: defaultPort),
      ]);

  Future<Change<Setting>?> savePreferredWalletId(String walletId) async =>
      save(Setting(name: SettingName.wallet_preferred, value: walletId));

  Future<Change<Setting>?> setCurrentWalletId([String? walletId]) async =>
      save(Setting(
          name: SettingName.wallet_current,
          value: walletId ?? preferredWalletId));

  bool get mainnet =>
      primaryIndex.getOne(SettingName.electrum_net)!.value == Net.main;

  NetworkType get network => chainNet.network;

  String get netName => net.name;

  List<DateTime> get loginAttempts =>
      primaryIndex.getOne(SettingName.login_attempts)!.value as List<DateTime>;

  Future<Change<Setting>?> saveLoginAttempts(List<DateTime> attempts) async =>
      save(Setting(name: SettingName.login_attempts, value: attempts));

  Future<Change<Setting>?> incrementLoginAttempts() async =>
      saveLoginAttempts(loginAttempts + <DateTime>[DateTime.now()]);

  Future<Change<Setting>?> resetLoginAttempts() async =>
      saveLoginAttempts(<DateTime>[]);

  Future<void> setBlockchain({
    Chain chain = Chain.ravencoin,
    Net net = Net.main,
  }) async {
    await saveAll(<Setting>[
      Setting(name: SettingName.electrum_net, value: net),
      Setting(name: SettingName.blockchain, value: chain)
    ]);
    await setDomainPortForChainNet();
  }

  /// triggers should be set to change the domain:port by chain:net
  /// for now we'll put it here:
  Future<List<Change<dynamic>>> setDomainPortForChainNet() async =>
      saveAll(<Setting>[
        Setting(name: SettingName.electrum_port, value: chainNet.port),
        Setting(name: SettingName.electrum_domain, value: chainNet.domain),
      ]);

  AuthMethod? get authMethod =>
      primaryIndex.getOne(SettingName.auth_method)?.value as AuthMethod?;

  bool get authMethodIsNativeSecurity =>
      primaryIndex.getOne(SettingName.auth_method)!.value ==
      AuthMethod.nativeSecurity;
}
