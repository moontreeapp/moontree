import 'package:raven_back/utilities/hex.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart'
    show KPWallet, NetworkType, ECPair;

import 'package:raven_back/raven_back.dart';

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
    String? name,
  }) {
    wif = wif ?? generateRandomWIF(res.settings.network);
    final encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    final existingWallet =
        res.wallets.primaryIndex.getOne(encryptedWIF.walletId);
    if (existingWallet == null) {
      final newWallet = SingleWallet(
          id: encryptedWIF.walletId,
          encryptedWIF: encryptedWIF.encryptedSecret,
          cipherUpdate: cipherUpdate,
          name: name ?? res.wallets.nextWalletName);
      final address = services.wallet.single.toAddress(newWallet);
      print('address from KPWallet: ${address.walletId}');
      services.client.subscribe.toAddress(address);
      return newWallet;
    }
    if (alwaysReturn) return existingWallet as SingleWallet;
    return null;
  }

  Future<void> makeSaveSingleWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? wif,
    String? name,
  }) async {
    var singleWallet = makeSingleWallet(
      cipher,
      cipherUpdate: cipherUpdate,
      wif: wif,
      name: name,
    );
    if (singleWallet != null) {
      await res.wallets.save(singleWallet);
    }
  }

  KPWallet getChangeWallet(SingleWallet wallet) => getKPWallet(wallet);
}
