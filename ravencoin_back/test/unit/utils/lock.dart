// dart test test/unit/utils/random.dart
import 'dart:math';

import 'package:test/test.dart';
import 'package:ravencoin_back/utilities/lock.dart';

void main() {
  test('Test Lock', () async {
    final lock = ReaderWriterLock();
    final rand = Random();

    var read_1 = () async {
      await lock.enterRead();
      print('1 Enter Read');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('1 Exit Read');
      await lock.exitRead();
    };
    var read_2 = () async {
      await lock.enterRead();
      print('2 Enter Read');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('2 Exit Read');
      await lock.exitRead();
    };
    var write_1 = () async {
      await lock.enterWrite();
      print('1 Enter Write');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('1 Exit Write');
      await lock.exitWrite();
    };
    var write_2 = () async {
      await lock.enterWrite();
      print('2 Enter Write');
      await Future<void>.delayed(
          Duration(milliseconds: 500 + rand.nextInt(2500)));
      print('2 Exit Write');
      await lock.exitWrite();
    };

    var w_1 = write_1();
    var r_1 = read_1();
    var w_2 = write_2();
    var r_2 = read_2();

    await Future.wait([r_1, r_2, w_1, w_2]);
  });
}
