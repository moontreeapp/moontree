import 'dart:io';

import 'package:test/test.dart';
import 'package:ravencoin_back/hive_initializer.dart';

void main() {
  group('HiveInitializer', () {
    test('database dir using string', () {
      var hiveInit = HiveInitializer(id: 'ok');
      expect(hiveInit.dbDir, 'database-ok');
    });

    test('database dir includes random suffix if id is unspecified', () {
      var hiveInit = HiveInitializer();
      expect(hiveInit.dbDir.startsWith('database-'), true);
      expect(hiveInit.dbDir.length, 35);
    });

    test('can setUp and tearDown', () async {
      var hiveInit = HiveInitializer(destroyOnTeardown: true);
      var dir = Directory(hiveInit.dbDir);

      await hiveInit.setUp(HiveLoadingStep.all);
      expect(await dir.exists(), true);

      await hiveInit.tearDown();
      expect(await dir.exists(), false);
    });
  });
}
