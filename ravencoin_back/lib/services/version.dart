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

import 'package:ravencoin_back/ravencoin_back.dart';

class VersionService {
  String byPlatform(String platform) => VERSIONS[platform]![VERSION_TRACK]!;
  VersionDescription? snapshot;

  /// preivous becomes current if diff, writes current, returns both in map
  Future<void> rotate(String latest) async {
    final previous =
        pros.settings.primaryIndex.getOne(SettingName.version_previous)?.value;
    final current =
        pros.settings.primaryIndex.getOne(SettingName.version_current)?.value;
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
                ?.value),
        current: current ??
            (pros.settings.primaryIndex
                .getOne(SettingName.version_current)
                ?.value),
        database: database ??
            (pros.settings.primaryIndex
                .getOne(SettingName.version_database)
                ?.value),
        latest: latest,
      );

  String? get current =>
      pros.settings.primaryIndex.getOne(SettingName.version_current)?.value;
}

class VersionDescription with ToStringMixin {
  final String? previous;
  final String? current;
  final String? latest;
  final int? database;

  VersionDescription({
    this.previous,
    this.current,
    this.latest,
    this.database,
  });

  @override
  List<Object?> get props => [
        previous,
        current,
        latest,
        database,
      ];

  @override
  List<String> get propNames => [
        'previous',
        'current',
        'latest',
        'database',
      ];

  String get currentMajor => current!.split('.').first;
  String get currentMinor => current!.split('.')[1];
  String get currentPatch => current!.split('.').last.split('+').first;
  String get currentBuild => current!.split('+').last.split('~').first;
  String get currentDatabase => current!.split('+').last.split('~').last;

  String get previousMajor => previous!.split('.').first;
  String get previousMinor => previous!.split('.')[1];
  String get previousPatch => previous!.split('.').last.split('+').first;
  String get previousBuild => previous!.split('+').last.split('~').first;
  String get previousDatabase => previous!.split('+').last.split('~').last;

  String get latestMajor => latest!.split('.').first;
  String get latestMinor => latest!.split('.')[1];
  String get latestPatch => latest!.split('.').last.split('+').first;
  String get latestBuild => latest!.split('+').last.split('~').first;
  String get latestDatabase => latest!.split('+').last.split('~').last;

  bool get updated => current != latest;
  bool get majorUpdated => currentMajor != latestMajor;
  bool get minorUpdated => currentMinor != latestMinor;
  bool get patchUpdated => currentPatch != latestPatch;
  bool get versionUpdated => majorUpdated || minorUpdated || patchUpdated;
  bool get buildUpdated => currentBuild != latestBuild;
  bool get databaseUpdated => currentDatabase != latestDatabase;

  bool get onlyBuildUpdated => !versionUpdated && buildUpdated;
}
