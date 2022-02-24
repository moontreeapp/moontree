import 'package:test/test.dart';
import 'package:reservoir/reservoir.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:raven_back/records/records.dart';
import 'package:raven_back/reservoirs/wallet.dart';
import '../../fixtures/mnemonic.dart';

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
          id: '0', encryptedEntropy: bip39.mnemonicToEntropy(mnemonic));
      await res.save(wallet);
      expect(res.primaryIndex.getOne(wallet.id), wallet);
    });
  });
}
