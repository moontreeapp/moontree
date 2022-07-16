/// this service is to help us initialize hive in multiple steps across mutliple
/// startup pages.

import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/lock.dart';

enum HiveLoaded { True, False, Partial }

class DataLoadingHelper {
  final _loadedLock = ReaderWriterLock();
  HiveLoaded _loaded = HiveLoaded.False;
  late HiveInitializer hiveInit;

  DataLoadingHelper() {
    hiveInit = HiveInitializer(init: (dbDir) => Hive.initFlutter());
  }

  Future setupDatabase() async {
    await hiveInit.setUp(HiveLoadingStep.All);
  }

  Future setupDatabaseStart() async {
    await hiveInit.setUpStart();
  }

  Future setupDatabase1() async {
    await hiveInit.setUp(HiveLoadingStep.Lock);
  }

  Future setupDatabase2() async {
    await hiveInit.setUp(HiveLoadingStep.Login);
  }

  Future isPartiallyLoaded() async =>
      await _loadedLock.read(() => _loaded == HiveLoaded.Partial);

  Future isLoaded() async =>
      await _loadedLock.read(() => _loaded == HiveLoaded.True);

  Future setupWaiters() async {
    initWaiters(HiveLoadingStep.All);
    unawaited(waiters.app.logoutThread());
    //initListeners();
    //await pros.settings.save(
    //    Setting(name: SettingName.Local_Path, value: await Storage().localPath));
  }

  Future setupWaiters1() async {
    initWaiters(HiveLoadingStep.Lock);
    await _loadedLock.write(() => _loaded = HiveLoaded.Partial);
  }

  Future setupWaiters2() async {
    initWaiters(HiveLoadingStep.Login);
    unawaited(waiters.app.logoutThread());
    //initListeners();
    await _loadedLock.write(() => _loaded = HiveLoaded.True);
  }
}
