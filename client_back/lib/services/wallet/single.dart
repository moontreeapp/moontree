import 'dart:convert';

import 'package:client_back/utilities/address.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show KPWallet, NetworkType, ECPair;

import 'package:client_back/client_back.dart';

class SingleWalletService {
  Future<Address> toAddress(SingleWallet wallet) async {
    final KPWallet kpWallet = await wallet.kpWallet; //getKPWallet(wallet);
    return Address(
        scripthash: kpWallet.scripthash,
        h160: utf8.decode(hash160(kpWallet.pubKey!)),
        walletId: wallet.id,
        index: 0,
        exposure: NodeExposure.external);
  }

  bool gapSatisfied(SingleWallet wallet) => wallet.addresses.isNotEmpty;

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
    final EncryptedWIF encryptedWIF = EncryptedWIF.fromWIF(wif, cipher);
    final Wallet? existingWallet =
        pros.wallets.primaryIndex.getOne(encryptedWIF.walletId);
    if (existingWallet == null) {
      final SingleWallet newWallet = SingleWallet(
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
      final Address address = await services.wallet.single.toAddress(newWallet);
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
    final SingleWallet? singleWallet = await makeSingleWallet(
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
