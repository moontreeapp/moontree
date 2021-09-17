import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/cipher.dart' show AESCipher, NoCipher;
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;

class LeaderWalletGenerationService extends Service {
  late final WalletReservoir wallets;

  LeaderWalletGenerationService(this.wallets) : super();

  LeaderWallet? makeLeaderWallet(String accountId, {String? entropy}) {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    // TODO: use EncryptedEntropy class here to get values
    var leaderWallet = LeaderWallet(
        accountId: accountId,
        encryptedEntropy: LeaderWallet.encryptEntropy(entropy));
    if (wallets.primaryIndex.getOne(leaderWallet.walletId) == null) {
      return leaderWallet;
    }
  }

  Future<void> makeSaveLeaderWallet(String accountId,
      {String? mnemonic}) async {
    var leaderWallet = makeLeaderWallet(accountId,
        entropy: mnemonic != null ? bip39.mnemonicToEntropy(mnemonic) : null);
    if (leaderWallet != null) {
      await wallets.save(leaderWallet);
    }
  }
}
