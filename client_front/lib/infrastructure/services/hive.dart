/// this service is to help us initialize hive in multiple steps across mutliple
/// startup pages.

import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';

enum HiveLoaded { yes, no, partial }

class DataLoadingHelper {
  DataLoadingHelper() {
    hiveInit = HiveInitializer(init: (dynamic dbDir) => Hive.initFlutter());
  }
  final ReaderWriterLock _loadedLock = ReaderWriterLock();
  HiveLoaded _loaded = HiveLoaded.no;
  late HiveInitializer hiveInit;

  Future<void> setupDatabase() async => hiveInit.setUp(HiveLoadingStep.all);

  Future<void> setupDatabaseStart() async => hiveInit.setUpStart();

  Future<void> setupDatabase1() async => hiveInit.setUp(HiveLoadingStep.lock);

  Future<void> setupDatabase2() async => hiveInit.setUp(HiveLoadingStep.login);

  Future<bool> isPartiallyLoaded() async =>
      _loadedLock.read(() => _loaded == HiveLoaded.partial);

  Future<bool> isLoaded() async =>
      _loadedLock.read(() => _loaded == HiveLoaded.yes);

  Future<void> setupWaiters() async {
    initTriggers(HiveLoadingStep.all);
    unawaited(triggers.app.logoutThread());
    //initListeners();
    //await pros.settings.save(
    //    Setting(name: SettingName.Local_Path, value: await Storage().localPath));
  }

  Future<void> setupWaiters1() async {
    initTriggers(HiveLoadingStep.lock);
    await _loadedLock.write(() => _loaded = HiveLoaded.partial);
  }

  Future<void> setupWaiters2() async {
    initTriggers(HiveLoadingStep.login);
    unawaited(triggers.app.logoutThread());
    //initListeners();
    await _loadedLock.write(() => _loaded = HiveLoaded.yes);
  }
}
