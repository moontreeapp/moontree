import 'dart:html';

import 'package:ravencoin_back/utilities/hex.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart'
    show KPWallet, NetworkType, ECPair;

import 'package:ravencoin_back/ravencoin_back.dart';

class SingleWalletService {
  Future<Address> toAddress(SingleWallet wallet) async {
    var net = pros.settings.net;
    var kpWallet = await wallet.kpWallet; //getKPWallet(wallet);
    return Address(
      id: kpWallet.scripthash,
      address: kpWallet.address!,
      walletId: wallet.id,
      exposure: NodeExposure.External, // ignored on singles.
      hdIndex: 0,
      chain: pros.settings.chain,
      net: net,
    );
  }

  KPWallet getKPWallet(SingleWallet wallet) => KPWallet.fromWIF(
      EncryptedWIF(wallet.encryptedWIF, wallet.cipher!).wif,
      pros.settings.network);

  KPWallet getKPWalletFromPrivKey(String privKey) => KPWallet.fromWIF(
      ECPair.fromPrivateKey(decode(privKey), network: pros.settings.network)
          .toWIF(),
      pros.settings.network);

  String privateKeyToWif(String privKey) =>
      ECPair.fromPrivateKey(decode(privKey)).toWIF();

  /// generate random entropy, transform into wallet, get wif.
  String generateRandomWIF(NetworkType network) =>
      KPWallet.random(network).wif!;

  Future<SingleWallet?> makeSingleWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? wif,
    bool alwaysReturn = false,
    String? name,
    Future<String> Function(String id)? getWif,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    wif = wif ?? generateRandomWIF(pros.settings.network);
    final encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    final existingWallet =
        pros.wallets.primaryIndex.getOne(encryptedWIF.walletId);
    if (existingWallet == null) {
      final newWallet = SingleWallet(
        id: encryptedWIF.walletId,
        encryptedWIF: '', //encryptedWIF.encryptedSecret,
        cipherUpdate: cipherUpdate,
        name: name ?? pros.wallets.nextWalletName,
        getWif: getWif,
      );
      if (saveSecret != null) {
        await saveSecret(Secret(
          secret: encryptedWIF.encryptedSecret,
          secretType: SecretType.encryptedWif,
          scripthash: encryptedWIF.walletId,
        ));
      }
      // TODO: shouldn't we save this to the address pros? and it will subscribe for us...?
      final address = await services.wallet.single.toAddress(newWallet);
      print('address from KPWallet: ${address.walletId}');
      //await services.client.subscribe.toAddress(address);
      return newWallet;
    }
    if (alwaysReturn) return existingWallet as SingleWallet;
    return null;
  }

  Future<SingleWallet?> makeSaveSingleWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? wif,
    String? name,
    Future<String> Function(String id)? getWif,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    wif = wif ?? generateRandomWIF(pros.settings.network);
    var singleWallet = await makeSingleWallet(
      cipher,
      cipherUpdate: cipherUpdate,
      wif: wif,
      name: name,
      getWif: getWif,
      saveSecret: saveSecret,
    );
    if (singleWallet != null) {
      await pros.wallets.save(singleWallet);
      return singleWallet;
    }
    return null;
  }

  KPWallet getChangeWallet(SingleWallet wallet) => getKPWallet(wallet);
}
