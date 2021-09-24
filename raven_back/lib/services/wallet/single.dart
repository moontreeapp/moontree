import 'package:ravencoin/ravencoin.dart' show KPWallet, NetworkType;

import 'package:raven/security/cipher.dart';
import 'package:raven/security/encrypted_wif.dart';
import 'package:raven/raven.dart';

class SingleWalletService {
  Address toAddress(SingleWallet wallet, Cipher cipher) {
    var net = accounts.primaryIndex.getOne(wallet.accountId)!.net;
    var kpWallet = getKPWallet(wallet);
    return Address(
        scripthash: kpWallet.scripthash,
        address: kpWallet.address!,
        walletId: wallet.walletId,
        hdIndex: 0,
        net: net);
  }

  KPWallet getKPWallet(SingleWallet wallet) =>
      KPWallet.fromWIF(EncryptedWIF(wallet.encryptedWIF, wallet.cipher!).wif);

  /// generate random entropy, transform into wallet, get wif.
  String generateRandomWIF(NetworkType network) =>
      KPWallet.random(network).wif!;

  SingleWallet? makeSingleWallet(String accountId, Cipher cipher,
      {required CipherUpdate cipherUpdate, String? wif}) {
    wif = wif ??
        generateRandomWIF(accounts.primaryIndex.getOne(accountId)!.network);
    var encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    if (wallets.primaryIndex.getOne(encryptedWIF.walletId) == null) {
      return SingleWallet(
          walletId: encryptedWIF.walletId,
          accountId: accountId,
          encryptedWIF: encryptedWIF.encryptedSecret,
          cipherUpdate: cipherUpdate);
    }
  }

  Future<void> makeSaveSingleWallet(String accountId, Cipher cipher,
      {required CipherUpdate cipherUpdate, String? wif}) async {
    var singleWallet = makeSingleWallet(accountId, cipher,
        cipherUpdate: cipherUpdate, wif: wif);
    if (singleWallet != null) {
      await wallets.save(singleWallet);
    }
  }
}
