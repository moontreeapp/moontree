import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/records/records.dart';

import 'package:raven/reservoirs/wallet.dart';
import 'package:reservoir/reservoir.dart';

void main() {
  group('Wallet Reservoir', () {
    late MapSource<Wallet> source;
    late WalletReservoir res;

    setUp(() {
      source = MapSource();
      res = WalletReservoir(source);
    });

    test('save a Wallet', () async {
      var encryptedSeed = Uint8List(16);
      var wallet =
          LeaderWallet(id: '0', accountId: 'a1', encryptedSeed: encryptedSeed);
      await res.save(wallet);
      expect(res.primaryIndex.getOne(wallet.id), wallet);
    });
  });
}
