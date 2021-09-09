import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/random.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:raven/utils/cipher.dart' show NoCipher;

// generates a leader wallet
class LeaderWalletGenerationService extends Service {
  late final WalletReservoir wallets;

  LeaderWalletGenerationService(this.wallets) : super();

  LeaderWallet newLeaderWallet(Account account, {Uint8List? seed}) {
    seed = seed ?? randomBytes(16);
    var seededWallet = HDWallet.fromSeed(seed, network: account.network);
    return LeaderWallet(
        walletId: seededWallet.address!,
        accountId: account.accountId,
        encryptedSeed: NoCipher().encrypt(seed));
  }

  void makeAndSaveLeaderWallet(Account account, {Uint8List? seed}) {
    wallets.save(newLeaderWallet(account, seed: seed));
  }
}
