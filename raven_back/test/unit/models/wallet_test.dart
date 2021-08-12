import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/records.dart' as records;
import 'package:raven/models.dart' as models;

import '../../reservoir/helper.dart';

void main() {
  group('Wallet Reservoir', () {
    late RxMapSource source;
    late Reservoir res;

    setUp(() {
      source = RxMapSource();
      res = Reservoir(
          source,
          (record) => models.LeaderWallet.fromRecord(record),
          (model) => model.toRecord());
      res.addPrimaryIndex((item) => item.walletId);
    });

    test('save an Wallet model', () async {
      var seed = Uint8List(16);
      var wallet = models.LeaderWallet(seed: seed);
      await asyncChange(res, () => res.save(wallet)); // fails?
      expect(res.get(wallet.id), wallet);
    });
  });

  group('Wallet', () {
    test('convert from record', () {
      var record = records.LeaderWallet(
          accountId: '', id: '0', encryptedSeed: Uint8List(16));
      expect(record.encryptedSeed, Uint8List(16));
    });

    test('convert to record', () {
      var seed = Uint8List(16);
      var model = models.LeaderWallet(seed: seed);
      var record = model.toRecord();
      expect(record.encrypted, seed); // NoCipher means seed == encryptedSeed
    });
  });
}
