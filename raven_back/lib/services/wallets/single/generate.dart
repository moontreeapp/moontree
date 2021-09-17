import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/cipher.dart' show Cipher, NoCipher;
import 'package:raven/utils/encrypted_entropy.dart';
import 'package:raven/utils/random.dart';
import 'package:ravencoin/ravencoin.dart'
    show ECPair, HDWallet, KPWallet, NetworkType, P2PKH, PaymentData;
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;

// generates a single wallet
class SingleWalletGenerationService extends Service {
  late final WalletReservoir wallets;
  late final AccountReservoir accounts;

  SingleWalletGenerationService(this.wallets, this.accounts) : super();

  /// generate random entropy, transform into wallet, get wif.
  String generateRandomWIF(NetworkType network) =>
      KPWallet.random(network).wif!;

  SingleWallet? makeSingleWallet(String accountId, Cipher cipher,
      {String? wif}) {
    wif = wif ??
        generateRandomWIF(accounts.primaryIndex.getOne(accountId)!.network);
    var encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    if (wallets.primaryIndex.getOne(encryptedWIF.walletId) == null) {
      return SingleWallet(
          walletId: encryptedWIF.walletId,
          accountId: accountId,
          encryptedWIF: encryptedWIF.encryptedWIF);
    }
  }

  Future<void> makeSaveSingleWallet(String accountId, Cipher cipher,
      {String? wif}) async {
    var singleWallet = makeSingleWallet(accountId, cipher, wif: wif);
    if (singleWallet != null) {
      await wallets.save(singleWallet);
    }
  }
}
