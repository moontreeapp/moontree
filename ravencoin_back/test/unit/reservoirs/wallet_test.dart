import 'package:test/test.dart';
import 'package:proclaim/proclaim.dart';
import 'package:bip39/bip39.dart' as bip39;

import 'package:ravencoin_back/records/records.dart';
import 'package:ravencoin_back/proclaim/wallet.dart';
import '../../fixtures/mnemonic.dart';

void main() {
  group('Wallet Proclaim', () {
    late MapSource<Wallet> source;
    late WalletProclaim res;

    setUp(() {
      source = MapSource();
      res = WalletProclaim()..setSource(source);
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
