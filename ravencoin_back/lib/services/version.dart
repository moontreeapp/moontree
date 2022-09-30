/// having current and perivous versions lets us do logic on state changes:
/// 1. previous != current != newVersion (first time run after update)
/// 2. previous != current == newVersion (has updated, but not recently)
/// 3. previous == current != newVersion (odd case)
/// 4. previous == current == newVersion (first version?)
///
/// we can use the first case to run migration code on their first run.
/// we can use the 2nd case in case of strange issues, maybe migration code
/// didn't finish or something, we'll still know what the old current versoin
/// was (now what the previous version is) so maybe we can recover.
/// the other cases shouldn't happen.
/// rotation occures right after settings are loaded. we can capture the
/// previous previous version if we want at that call.

import 'package:ravencoin_back/ravencoin_back.dart';

class VersionService {
  String byPlatform(String platform) => VERSIONS[platform]![VERSION_TRACK]!;

  /// preivous becomes current if diff, writes current, returns both in map
  Future<VersionDescription> rotate(String newVersion) async {
    final previous =
        pros.settings.primaryIndex.getOne(SettingName.Version_Previous)?.value;
    final current =
        pros.settings.primaryIndex.getOne(SettingName.Version_Current)?.value;
    if (newVersion != current) {
      await pros.settings.save(Setting(
        name: SettingName.Version_Previous,
        value: current,
      ));
      await pros.settings.save(Setting(
        name: SettingName.Version_Current,
        value: newVersion,
      ));
    }
    return all(
      previous: previous,
      current: current,
      newVersion: newVersion,
    );
  }

  VersionDescription all({
    String? previous,
    String? current,
    String? newVersion,
    int? database,
  }) =>
      VersionDescription(
        previous: previous ??
            (pros.settings.primaryIndex
                .getOne(SettingName.Version_Previous)
                ?.value),
        current: current ??
            (pros.settings.primaryIndex
                .getOne(SettingName.Version_Current)
                ?.value),
        database: database ??
            (pros.settings.primaryIndex
                .getOne(SettingName.Version_Database)
                ?.value),
        newVersion: newVersion,
      );

  String? get current =>
      pros.settings.primaryIndex.getOne(SettingName.Version_Current)?.value;
}

class VersionDescription with ToStringMixin {
  final String? previous;
  final String? current;
  final String? newVersion;
  final int? database;

  VersionDescription({
    this.previous,
    this.current,
    this.newVersion,
    this.database,
  });

  @override
  List<Object?> get props => [
        previous,
        current,
        newVersion,
        database,
      ];

  @override
  List<String> get propNames => [
        'previous',
        'current',
        'newVersion',
        'database',
      ];
}
