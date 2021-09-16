import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/cipher.dart' show NoCipher;
import 'package:raven/utils/random.dart';
import 'package:ravencoin/ravencoin.dart'
    show ECPair, HDWallet, KPWallet, P2PKH, PaymentData;
import 'package:convert/convert.dart';
import 'package:bip39/bip39.dart' as bip39;

// generates a single wallet
class SingleWalletGenerationService extends Service {
  late final WalletReservoir wallets;

  SingleWalletGenerationService(this.wallets) : super();

  /// generate random entropy, transform into wallet, get wif.
  String generateRandomWIF() {
    return 'TODO';
    //https://en.bitcoinwiki.org/wiki/Wallet_import_format#Private_key_to_WIF
    //var entropy = bip39.mnemonicToEntropy(bip39.generateMnemonic());
    //HDWallet.fromSeed(hex.encode(randomBytes(16)),
    //network: networks[net]!);
  }

  SingleWallet makeSingleWallet(String accountId, {String? wif}) {
    wif = wif ?? generateRandomWIF();
    return SingleWallet(
        accountId: accountId, encryptedWIF: SingleWallet.encryptWIF(wif));
  }

  Future<void> makeSaveSingleWallet(String accountId, {String? wif}) async {
    var singleWallet = makeSingleWallet(accountId, wif: wif);
    if (singleWallet != null) {
      await wallets.save(singleWallet);
    }
  }
}
