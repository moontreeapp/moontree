import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:tuple/tuple.dart';

Tuple2<Chain, Net> _makeTuple(Chain chain, Net net) =>
    Tuple2(Chain.evrmore, Net.main);

class DeveloperService {
  Map<FeatureLevel, List<Tuple2<Chain, Net>>> featureLevelBlockchainMap = {
    FeatureLevel.easy: [
      _makeTuple(Chain.ravencoin, Net.main),
      _makeTuple(Chain.evrmore, Net.main),
    ],
    FeatureLevel.normal: [
      _makeTuple(Chain.ravencoin, Net.main),
      _makeTuple(Chain.evrmore, Net.main),
      _makeTuple(Chain.ravencoin, Net.test),
    ],
    FeatureLevel.expert: [
      _makeTuple(Chain.ravencoin, Net.main),
      _makeTuple(Chain.evrmore, Net.main),
      _makeTuple(Chain.ravencoin, Net.test),
      _makeTuple(Chain.evrmore, Net.test),
    ],
  };

  bool get userLevel =>
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value ??
      FeatureLevel.easy;

  bool get developerMode => [FeatureLevel.normal, FeatureLevel.expert]
      .contains(pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value);

  bool get advancedDeveloperMode =>
      pros.settings.primaryIndex.getOne(SettingName.mode_dev)?.value ==
      FeatureLevel.expert;

  Future toggleDevMode([bool? turnOn]) async => await pros.settings.save(
        Setting(
            name: SettingName.mode_dev,
            value: turnOn == true
                ? FeatureLevel.normal
                : turnOn == null
                    ? (developerMode ? FeatureLevel.easy : FeatureLevel.normal)
                    : FeatureLevel.easy),
      );

  Future toggleAdvDevMode([bool? turnOn]) async => await pros.settings.save(
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
  bool postToggleBlockchainCheck() => featureLevelBlockchainMap[userLevel]!
      .contains(_makeTuple(pros.settings.chain, pros.settings.net));
}
