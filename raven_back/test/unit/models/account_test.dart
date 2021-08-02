import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/records.dart' as records;
import 'package:raven/models.dart' as models;

import '../../reservoir/helper.dart';

void main() {
  group('Account Reservoir', () {
    late RxMapSource source;
    late Reservoir res;

    setUp(() {
      source = RxMapSource();
      res = Reservoir(source, (record) => models.Account.fromRecord(record),
          (model) => model.toRecord());
    });

    test('save an Account model', () async {
      var seed = Uint8List(16);
      var account = models.Account(seed, name: 'in-memory wallet');
      await asyncChange(res, () => res.save(account));
      expect(res.data[account.accountId], account);
    });
  });

  group('Account', () {
    test('convert from record', () {
      var encSeed = Uint8List(16);
      var record = records.Account(encSeed, name: '1st Wallet');
      var model = models.Account.fromRecord(record);
      expect(model.encryptedSeed, encSeed);
      expect(model.name, '1st Wallet');
    });

    test('convert to record', () {
      var seed = Uint8List(16);
      var model = models.Account(seed, name: '1st Wallet');
      var record = model.toRecord();
      expect(
          record.encryptedSeed, seed); // NoCipher means seed == encryptedSeed
      expect(record.name, '1st Wallet');
    });
  });
}
