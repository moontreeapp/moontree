import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/random.dart';
import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:raven/utils/cipher.dart' show NoCipher;

class LeaderWalletGenerationService extends Service {
  late final WalletReservoir wallets;

  LeaderWalletGenerationService(this.wallets) : super();

  /// used to create the address which is the walletId
  HDWallet createHDWallet(Account account, {Uint8List? seed}) {
    return HDWallet.fromSeed(seed ?? randomBytes(16), network: account.network);
  }

  LeaderWallet? makeLeaderWallet(Account account, {Uint8List? seed}) {
    var seededWallet = createHDWallet(account, seed: seed);
    if (wallets.primaryIndex.getOne(seededWallet.address!) == null) {
      return LeaderWallet(
          walletId: seededWallet.address!,
          accountId: account.accountId,
          encryptedSeed: NoCipher().encrypt(seededWallet.seed!));
    }
  }

  void makeSaveLeaderWallet(Account account, {Uint8List? seed}) {
    var leaderWallet = makeLeaderWallet(account, seed: seed);
    if (leaderWallet != null) {
      wallets.save(leaderWallet);
    }
  }
}
