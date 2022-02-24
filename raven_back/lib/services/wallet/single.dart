import 'package:raven_back/utils/hex.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart'
    show KPWallet, NetworkType, ECPair;

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/security/cipher_base.dart';
import 'package:raven_back/security/encrypted_wif.dart';

class SingleWalletService {
  Address toAddress(SingleWallet wallet) {
    var net = res.settings.net;
    var kpWallet = getKPWallet(wallet);
    return Address(
        id: kpWallet.scripthash,
        address: kpWallet.address!,
        walletId: wallet.id,
        hdIndex: 0,
        net: net);
  }

  KPWallet getKPWallet(SingleWallet wallet) =>
      KPWallet.fromWIF(EncryptedWIF(wallet.encryptedWIF, wallet.cipher!).wif);

  KPWallet getKPWalletFromPrivKey(String privKey) =>
      KPWallet.fromWIF(ECPair.fromPrivateKey(decode(privKey)).toWIF());
  String privateKeyToWif(String privKey) =>
      ECPair.fromPrivateKey(decode(privKey)).toWIF();

  /// generate random entropy, transform into wallet, get wif.
  String generateRandomWIF(NetworkType network) =>
      KPWallet.random(network).wif!;

  SingleWallet? makeSingleWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? wif,
    bool alwaysReturn = false,
  }) {
    wif = wif ?? generateRandomWIF(res.settings.network);
    var encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    var existingWallet = res.wallets.primaryIndex.getOne(encryptedWIF.walletId);
    if (existingWallet == null) {
      return SingleWallet(
          id: encryptedWIF.walletId,
          encryptedWIF: encryptedWIF.encryptedSecret,
          cipherUpdate: cipherUpdate);
    }
    if (alwaysReturn) return existingWallet as SingleWallet;
  }

  Future<void> makeSaveSingleWallet(CipherBase cipher,
      {required CipherUpdate cipherUpdate, String? wif}) async {
    var singleWallet =
        makeSingleWallet(cipher, cipherUpdate: cipherUpdate, wif: wif);
    if (singleWallet != null) {
      await res.wallets.save(singleWallet);
    }
  }

  KPWallet getChangeWallet(SingleWallet wallet) => getKPWallet(wallet);
}
