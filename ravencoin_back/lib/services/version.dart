/// having current and perivous versions lets us do logic on state changes:
/// 1. previous != current != latest (first time run after update)
/// 2. previous != current == latest (has updated, but not recently)
/// 3. previous == current != latest (odd case)
/// 4. previous == current == latest (first version?)
///
/// we can use the first case to run migration code on their first run.
/// we can use the 2nd case in case of strange issues, maybe migration code
/// didn't finish or something, we'll still know what the old current versoin
/// was (now what the previous version is) so maybe we can recover.
/// the other cases shouldn't happen.
/// rotation occures right after settings are loaded. we can capture the
/// previous previous version if we want at that call.

import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class VersionService {
  String byPlatform(String platform) => VERSIONS[platform]![VERSION_TRACK]!;
  VersionDescription? snapshot;

  /// preivous becomes current if diff, writes current, returns both in map
  Future<void> rotate(String latest) async {
    final String? previous = pros.settings.primaryIndex
        .getOne(SettingName.version_previous)
        ?.value as String?;
    final String? current = pros.settings.primaryIndex
        .getOne(SettingName.version_current)
        ?.value as String?;
    if (latest != current) {
      await pros.settings.save(Setting(
        name: SettingName.version_previous,
        value: current,
      ));
      await pros.settings.save(Setting(
        name: SettingName.version_current,
        value: latest,
      ));
    }
    snapshot = all(
      previous: previous,
      current: current,
      latest: latest,
    );
  }

  VersionDescription all({
    String? previous,
    String? current,
    String? latest,
    int? database,
  }) =>
      VersionDescription(
        previous: previous ??
            (pros.settings.primaryIndex
                .getOne(SettingName.version_previous)
                ?.value as String?),
        current: current ??
            (pros.settings.primaryIndex
                .getOne(SettingName.version_current)
                ?.value as String?),
        database: database ??
            (pros.settings.primaryIndex
                .getOne(SettingName.version_database)
                ?.value as int?),
        latest: latest,
      );

  String? get current =>
      pros.settings.primaryIndex.getOne(SettingName.version_current)?.value
          as String?;
}

class VersionDescription with ToStringMixin {
  VersionDescription({
    this.previous,
    this.current,
    this.latest,
    this.database,
  });
  final String? previous;
  final String? current;
  final String? latest;
  final int? database;

  @override
  List<Object?> get props => <Object?>[
        previous,
        current,
        latest,
        database,
      ];

  @override
  List<String> get propNames => <String>[
        'previous',
        'current',
        'latest',
        'database',
      ];

  int get currentMajor => int.parse(current!.split('.').first);
  int get currentMinor => int.parse(current!.split('.')[1]);
  int get currentPatch => int.parse(current!.split('.').last.split('+').first);
  int get currentBuild => int.parse(current!.split('+').last.split('~').first);
  int get currentDatabase =>
      int.parse(current!.split('+').last.split('~').last);

  int get previousMajor => int.parse(previous!.split('.').first);
  int get previousMinor => int.parse(previous!.split('.')[1]);
  int get previousPatch =>
      int.parse(previous!.split('.').last.split('+').first);
  int get previousBuild =>
      int.parse(previous!.split('+').last.split('~').first);
  int get previousDatabase =>
      int.parse(previous!.split('+').last.split('~').last);

  int get latestMajor => int.parse(latest!.split('.').first);
  int get latestMinor => int.parse(latest!.split('.')[1]);
  int get latestPatch => int.parse(latest!.split('.').last.split('+').first);
  int get latestBuild => int.parse(latest!.split('+').last.split('~').first);
  int get latestDatabase => int.parse(latest!.split('+').last.split('~').last);

  bool get updated => current != latest;
  bool get majorUpdated => currentMajor != latestMajor;
  bool get minorUpdated => currentMinor != latestMinor;
  bool get patchUpdated => currentPatch != latestPatch;
  bool get versionUpdated => majorUpdated || minorUpdated || patchUpdated;
  bool get buildUpdated => currentBuild != latestBuild;
  bool get databaseUpdated => currentDatabase != latestDatabase;

  bool get onlyBuildUpdated => !versionUpdated && buildUpdated;
}
