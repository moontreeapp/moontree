import 'package:ravencoin_back/ravencoin_back.dart';

class DeveloperService {
  Map<FeatureLevel, List<ChainNet>> featureLevelBlockchainMap =
      <FeatureLevel, List<ChainNet>>{
    FeatureLevel.easy: <ChainNet>[
      ChainNet(Chain.evrmore, Net.main),
      ChainNet(Chain.ravencoin, Net.main),
    ],
    FeatureLevel.normal: <ChainNet>[
      ChainNet(Chain.evrmore, Net.main),
      ChainNet(Chain.ravencoin, Net.main),
      ChainNet(Chain.ravencoin, Net.test),
    ],
    FeatureLevel.expert: <ChainNet>[
      ChainNet(Chain.evrmore, Net.main),
      ChainNet(Chain.ravencoin, Net.main),
      ChainNet(Chain.evrmore, Net.test),
      ChainNet(Chain.ravencoin, Net.test),
    ],
  };

  FeatureLevel get userLevel =>
      (pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value
          as FeatureLevel?) ??
      FeatureLevel.easy;

  bool get easyMode =>
      FeatureLevel.easy ==
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value;

  bool get developerMode =>
      <FeatureLevel>[FeatureLevel.normal, FeatureLevel.expert].contains(
          pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value);

  bool get advancedDeveloperMode =>
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value ==
      FeatureLevel.expert;

  Future<void> toggleDevMode([bool? turnOn]) async => pros.settings.save(
        Setting(
            name: SettingName.mode_dev,
            value: turnOn == null
                ? (developerMode ? FeatureLevel.easy : FeatureLevel.normal)
                : turnOn == true
                    ? FeatureLevel.normal
                    : FeatureLevel.easy),
      );

  Future<void> toggleAdvDevMode([bool? turnOn]) async => pros.settings.save(
        Setting(
            name: SettingName.mode_dev,
            value: turnOn == null
                ? (advancedDeveloperMode
                    ? FeatureLevel.easy
                    : FeatureLevel.expert)
                : turnOn == true
                    ? FeatureLevel.expert
                    : FeatureLevel.easy),
      );

  /// indicates we should turns off settings unavailable to non-developers
  ChainNet? postToggleBlockchainCheck() {
    if (!featureLevelBlockchainMap[userLevel]!
        .contains(ChainNet(pros.settings.chain, pros.settings.net))) {
      if (pros.settings.net == Net.test &&
          services.developer
              .featureLevelBlockchainMap[services.developer.userLevel]!
              .contains(ChainNet(pros.settings.chain, Net.main))) {
        return ChainNet(pros.settings.chain, Net.main);
      } else {
        return ChainNet(Chain.ravencoin, Net.main);
      }
    }
    return null;
  }

  /// turns out this isn't needed yet - it's where we can turn off settings if
  /// they go back to easy mode and the current settings are not available in
  /// that mode. there are no settings they can change right now, miner mode
  /// used to be a dev mode thing, but now it's not so that's the example here:
  Future<void> postToggleFeatureCheck() async {
    //  if (!easyMode) return;
    //  for (var wallet in pros.wallets.records) {
    //    if (services.wallet.currentWallet.minerMode) {
    //      await services.wallet.setMinerMode(false, wallet: wallet);
    //    }
    //  }
  }
}
