import 'package:raven_back/utils/hex.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart'
    show KPWallet, NetworkType, ECPair;

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/security/cipher_base.dart';
import 'package:raven_back/security/encrypted_wif.dart';

class SingleWalletService {
  Address toAddress(SingleWallet wallet) {
    var net = res.accounts.primaryIndex.getOne(wallet.accountId)!.net;
    var kpWallet = getKPWallet(wallet);
    return Address(
        addressId: kpWallet.scripthash,
        address: kpWallet.address!,
        walletId: wallet.walletId,
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

  SingleWallet? makeSingleWallet(String accountId, CipherBase cipher,
      {required CipherUpdate cipherUpdate,
      String? wif,
      bool alwaysReturn = false}) {
    wif = wif ??
        generateRandomWIF(res.accounts.primaryIndex.getOne(accountId)!.network);
    var encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    var existingWallet = res.wallets.primaryIndex.getOne(encryptedWIF.walletId);
    if (existingWallet == null) {
      return SingleWallet(
          walletId: encryptedWIF.walletId,
          accountId: accountId,
          encryptedWIF: encryptedWIF.encryptedSecret,
          cipherUpdate: cipherUpdate);
    }
    if (alwaysReturn) return existingWallet as SingleWallet;
  }

  Future<void> makeSaveSingleWallet(String accountId, CipherBase cipher,
      {required CipherUpdate cipherUpdate, String? wif}) async {
    var singleWallet = makeSingleWallet(accountId, cipher,
        cipherUpdate: cipherUpdate, wif: wif);
    if (singleWallet != null) {
      await res.wallets.save(singleWallet);
    }
  }

  KPWallet getChangeWallet(SingleWallet wallet) => getKPWallet(wallet);
}
