import 'package:ravencoin_wallet/ravencoin_wallet.dart' show ECPair, WalletBase;
import 'package:bip39/bip39.dart' as bip39;

import 'package:ravencoin_back/ravencoin_back.dart';

import 'wallet/leader.dart';
import 'wallet/single.dart';
import 'wallet/export.dart';
import 'wallet/import.dart';
import 'wallet/constants.dart';

class WalletService {
  final LeaderWalletService leader = LeaderWalletService();
  final SingleWalletService single = SingleWalletService();
  final ExportWalletService export = ExportWalletService();
  final ImportWalletService import = ImportWalletService();

  Wallet get currentWallet =>
      pros.wallets.primaryIndex.getOne(pros.settings.currentWalletId)!;

  // should return all cipherUpdates
  Set<CipherUpdate> get getAllCipherUpdates =>
      pros.wallets.records.map((wallet) => wallet.cipherUpdate).toSet();

  // should return cipherUpdates that must be used with current password...
  Set<CipherUpdate> get getCurrentCipherUpdates => pros.wallets.records
      .map((wallet) => wallet.cipherUpdate)
      .where((cipherUpdate) =>
          cipherUpdate.passwordId == pros.passwords.maxPasswordId)
      .toSet();

  // should return cipherUpdates that must be used with previous password...
  Set<CipherUpdate> get getPreviousCipherUpdates =>
      pros.passwords.maxPasswordId == null
          ? {}
          : pros.wallets.records
              .map((wallet) => wallet.cipherUpdate)
              .where((cipherUpdate) =>
                  cipherUpdate.cipherType != CipherType.None &&
                  cipherUpdate.passwordId! < pros.passwords.maxPasswordId!)
              .toSet();

  Future createSave({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    String? secret,
    String? name,
  }) async {
    if (walletType == WalletType.leader) {
      await leader.makeSaveLeaderWallet(
        pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        mnemonic: secret,
        name: name,
      );
    } else {
      //WalletType.single
      await single.makeSaveSingleWallet(
        pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        wif: secret,
        name: name,
      );
    }
  }

  Future generate() async => await services.wallet.createSave(
      walletType: WalletType.leader,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: null);

  Wallet? create({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String? secret,
    bool alwaysReturn = false,
  }) {
    switch (walletType) {
      case WalletType.leader:
        return leader.makeLeaderWallet(
          pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          entropy: secret != null ? bip39.mnemonicToEntropy(secret) : null,
          alwaysReturn: alwaysReturn,
        );
      case WalletType.single:
        return single.makeSingleWallet(
          pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          wif: secret,
          alwaysReturn: alwaysReturn,
        );
      default:
        return create(
          walletType: WalletType.leader,
          cipherUpdate: cipherUpdate,
          secret: secret,
          alwaysReturn: alwaysReturn,
        );
    }
  }

  ECPair getAddressKeypair(Address address) {
    var wallet = address.wallet;
    if (wallet is LeaderWallet) {
      var seedWallet = services.wallet.leader.getSeedWallet(wallet);
      var hdWallet =
          seedWallet.subwallet(address.hdIndex, exposure: address.exposure);
      return hdWallet.keyPair;
    } else if (wallet is SingleWallet) {
      var kpWallet = services.wallet.single.getKPWallet(wallet);
      return kpWallet.keyPair;
    } else {
      throw ArgumentError('wallet type unknown');
    }
  }

  /// gets the first empty address
  String getEmptyAddress(
    Wallet wallet,
    NodeExposure exposure, {
    String? address,
  }) =>
      address ?? wallet.minimumEmptyAddress(exposure).address; // all
  //address ?? wallet.firstEmptyInGap(exposure).address; // gap only
  /// actaully we should fill all the gaps first according to bip44 spec
}
