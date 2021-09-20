import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/security/cipher.dart' show CipherAES, Cipher, CipherNone;
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/security/encrypted_entropy.dart';

class LeaderWalletGenerationService extends Service {
  late final WalletReservoir wallets;

  LeaderWalletGenerationService(this.wallets) : super();

  LeaderWallet? makeLeaderWallet(String accountId, Cipher cipher,
      {String? entropy}) {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    var encryptedEntropy = EncryptedEntropy.fromEntropy(entropy, cipher);
    if (wallets.primaryIndex.getOne(encryptedEntropy.walletId) == null) {
      return LeaderWallet(
          walletId: encryptedEntropy.walletId,
          accountId: accountId,
          encryptedEntropy: encryptedEntropy.encryptedSecret);
    }
  }

  Future<void> makeSaveLeaderWallet(String accountId, Cipher cipher,
      {String? mnemonic}) async {
    var leaderWallet = makeLeaderWallet(accountId, cipher,
        entropy: mnemonic != null ? bip39.mnemonicToEntropy(mnemonic) : null);
    if (leaderWallet != null) {
      await wallets.save(leaderWallet);
    }
  }
}
