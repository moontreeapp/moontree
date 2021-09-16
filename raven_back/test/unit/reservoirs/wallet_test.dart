import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:raven/records/records.dart';

import 'package:raven/reservoirs/wallet.dart';
import 'package:reservoir/reservoir.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() {
  group('Wallet Reservoir', () {
    late MapSource<Wallet> source;
    late WalletReservoir res;

    setUp(() {
      source = MapSource();
      res = WalletReservoir()..setSource(source);
    });

    test('save a Wallet', () async {
      //var encryptedSeed = Uint8List(16);
      var wallet = LeaderWallet(
          walletId: '0',
          accountId: 'a1',
          encryptedEntropy:
              bip39.mnemonicToEntropy('00000000000000000000000000000000'));
      await res.save(wallet);
      expect(res.primaryIndex.getOne(wallet.walletId), wallet);
    });
  });
}
