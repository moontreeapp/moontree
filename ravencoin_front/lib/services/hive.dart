/// this service is to help us initialize hive in multiple steps across mutliple
/// startup pages.

import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/lock.dart';

enum HiveLoaded { yes, no, partial }

class DataLoadingHelper {
  final _loadedLock = ReaderWriterLock();
  HiveLoaded _loaded = HiveLoaded.no;
  late HiveInitializer hiveInit;

  DataLoadingHelper() {
    hiveInit = HiveInitializer(init: (dbDir) => Hive.initFlutter());
  }

  Future<void> setupDatabase() async {
    await hiveInit.setUp(HiveLoadingStep.all);
  }

  Future<void> setupDatabaseStart() async {
    await hiveInit.setUpStart();
  }

  Future<void> setupDatabase1() async {
    await hiveInit.setUp(HiveLoadingStep.lock);
  }

  Future<void> setupDatabase2() async {
    await hiveInit.setUp(HiveLoadingStep.login);
  }

  Future<bool> isPartiallyLoaded() async =>
      await _loadedLock.read(() => _loaded == HiveLoaded.partial);

  Future<bool> isLoaded() async =>
      await _loadedLock.read(() => _loaded == HiveLoaded.yes);

  Future<void> setupWaiters() async {
    initWaiters(HiveLoadingStep.all);
    unawaited(waiters.app.logoutThread());
    //initListeners();
    //await pros.settings.save(
    //    Setting(name: SettingName.Local_Path, value: await Storage().localPath));
  }

  Future<void> setupWaiters1() async {
    initWaiters(HiveLoadingStep.lock);
    await _loadedLock.write(() => _loaded = HiveLoaded.partial);
  }

  Future<void> setupWaiters2() async {
    initWaiters(HiveLoadingStep.login);
    unawaited(waiters.app.logoutThread());
    //initListeners();
    await _loadedLock.write(() => _loaded = HiveLoaded.yes);
  }
}
