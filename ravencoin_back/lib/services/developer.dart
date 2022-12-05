import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:tuple/tuple.dart';

Tuple2<Chain, Net> _makeTuple(Chain chain, Net net) => Tuple2(chain, net);

class DeveloperService {
  Map<FeatureLevel, List<Tuple2<Chain, Net>>> featureLevelBlockchainMap = {
    FeatureLevel.easy: [
      _makeTuple(Chain.evrmore, Net.main),
      _makeTuple(Chain.ravencoin, Net.main),
    ],
    FeatureLevel.normal: [
      _makeTuple(Chain.evrmore, Net.main),
      _makeTuple(Chain.ravencoin, Net.main),
      _makeTuple(Chain.ravencoin, Net.test),
    ],
    FeatureLevel.expert: [
      _makeTuple(Chain.evrmore, Net.main),
      _makeTuple(Chain.ravencoin, Net.main),
      _makeTuple(Chain.evrmore, Net.test),
      _makeTuple(Chain.ravencoin, Net.test),
    ],
  };

  FeatureLevel get userLevel =>
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value ??
      FeatureLevel.easy;

  bool get easyMode =>
      FeatureLevel.easy ==
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value;

  bool get developerMode => [FeatureLevel.normal, FeatureLevel.expert]
      .contains(pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value);

  bool get advancedDeveloperMode =>
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value ==
      FeatureLevel.expert;

  Future toggleDevMode([bool? turnOn]) async => pros.settings.save(
        Setting(
            name: SettingName.mode_dev,
            value: turnOn == true
                ? FeatureLevel.normal
                : turnOn == null
                    ? (developerMode ? FeatureLevel.easy : FeatureLevel.normal)
                    : FeatureLevel.easy),
      );

  Future toggleAdvDevMode([bool? turnOn]) async => pros.settings.save(
        Setting(
            name: SettingName.mode_dev,
            value: turnOn == true
                ? FeatureLevel.expert
                : turnOn == null
                    ? (advancedDeveloperMode
                        ? FeatureLevel.easy
                        : FeatureLevel.expert)
                    : FeatureLevel.easy),
      );

  /// indicates we should turns off settings unavailable to non-developers
  Tuple2<Chain, Net>? postToggleBlockchainCheck() {
    if (!featureLevelBlockchainMap[userLevel]!
        .contains(_makeTuple(pros.settings.chain, pros.settings.net))) {
      if (pros.settings.net == Net.test &&
          services.developer
              .featureLevelBlockchainMap[services.developer.userLevel]!
              .contains(Tuple2(pros.settings.chain, Net.main))) {
        return Tuple2(pros.settings.chain, Net.main);
      } else {
        return Tuple2(Chain.ravencoin, Net.main);
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
