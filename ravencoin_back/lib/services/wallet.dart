import 'package:wallet_utils/wallet_utils.dart' show ECPair, WalletBase;
import 'package:bip39/bip39.dart' as bip39;

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:tuple/tuple.dart';

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
                  cipherUpdate.cipherType != CipherType.none &&
                  cipherUpdate.passwordId! < pros.passwords.maxPasswordId!)
              .toSet();

  /// returns a pubkey, secret
  Future<Wallet?> createSave({
    WalletType? walletType,
    CipherUpdate? cipherUpdate,
    String? mnemonic,
    String? name,
    Future<String> Function(String id)? getSecret,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    cipherUpdate ??= services.cipher.currentCipherUpdate;
    walletType ??= WalletType.leader;
    if (walletType == WalletType.leader) {
      return await leader.makeSaveLeaderWallet(
        pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        mnemonic: mnemonic,
        name: name,
        getEntropy: getSecret,
        saveSecret: saveSecret,
      );
    } else {
      //WalletType.single
      return await single.makeSaveSingleWallet(
        pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        wif: mnemonic,
        name: name,
        getWif: getSecret,
        saveSecret: saveSecret,
      );
    }
  }

  Future generate() async => await services.wallet.createSave(
      walletType: WalletType.leader,
      cipherUpdate: services.cipher.currentCipherUpdate,
      mnemonic: null);

  Future<Wallet?> create({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String? secret,
    bool alwaysReturn = false,
    Future<String> Function(String id)? getSecret,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    switch (walletType) {
      case WalletType.leader:
        final entropy =
            bip39.mnemonicToEntropy(secret ?? bip39.generateMnemonic());
        final wallet = await leader.makeLeaderWallet(
          pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          entropy: entropy,
          alwaysReturn: alwaysReturn,
          getEntropy: getSecret,
          saveSecret: saveSecret,
        );
        return wallet;
      case WalletType.single:
        final wallet = await single.makeSingleWallet(
          pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          wif: secret!,
          alwaysReturn: alwaysReturn,
          getWif: getSecret,
          saveSecret: saveSecret,
        );
        return wallet!;
      default:
        return create(
          walletType: WalletType.leader,
          cipherUpdate: cipherUpdate,
          secret: secret,
          alwaysReturn: alwaysReturn,
          getSecret: getSecret,
        );
    }
  }

  Future<ECPair> getAddressKeypair(Address address) async {
    var wallet = address.wallet;
    if (wallet is LeaderWallet) {
      var seedWallet = await services.wallet.leader.getSeedWallet(wallet);
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

  /// this settings controls the behavior of this service
  Future setMinerMode(bool value, {Wallet? wallet}) async {
    wallet ??= currentWallet;
    if (wallet.skipHistory != value) {
      if (wallet is LeaderWallet) {
        await pros.wallets.save(LeaderWallet.from(
          wallet,
          skipHistory: value,
        ));
      } else if (wallet is SingleWallet) {
        await pros.wallets.save(SingleWallet.from(
          wallet,
          skipHistory: value,
        ));
      }
    }

    /// might belong in waiter but no need to make a new waiter just for this.
    if (value && wallet == currentWallet) {
      await services.download.queue.reset();
    } else {
      await services.download.queue.process();
    }
  }
}
