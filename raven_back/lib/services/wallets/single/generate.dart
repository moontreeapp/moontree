import 'dart:typed_data';

import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/cipher.dart' show NoCipher;
import 'package:ravencoin/ravencoin.dart'
    show ECPair, KPWallet, P2PKH, PaymentData;

// generates a single wallet
class SingleWalletGenerationService extends Service {
  late final WalletReservoir wallets;

  SingleWalletGenerationService(this.wallets) : super();

  SingleWallet newSingleWallet(
      {required Account account,
      required Uint8List privateKey,
      required bool compressed}) {
    var seededWallet = KPWallet(
        ECPair.fromPrivateKey(privateKey,
            network: account.network, compressed: compressed),
        P2PKH(data: PaymentData(), network: account.network),
        account.network);
    return SingleWallet(
        walletId: seededWallet.address!,
        accountId: account.accountId,
        encryptedPrivateKey: NoCipher().encrypt(privateKey));
  }

  void makeAndSaveSingleWallet(
          {required Account account,
          required Uint8List privateKey,
          required bool compressed}) =>
      wallets.save(newSingleWallet(
          account: account, privateKey: privateKey, compressed: compressed));
}
