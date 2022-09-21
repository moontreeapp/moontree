import 'package:ravencoin_wallet/ravencoin_wallet.dart' show ECPair, WalletBase;
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
                  cipherUpdate.cipherType != CipherType.None &&
                  cipherUpdate.passwordId! < pros.passwords.maxPasswordId!)
              .toSet();

  /// returns a pubkey, secret
  Future<Secret?> createSave({
    WalletType? walletType,
    CipherUpdate? cipherUpdate,
    String? mnemonic,
    String? name,
    Future<String> Function(String id)? getEntropy,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    cipherUpdate ??= services.cipher.currentCipherUpdate;
    walletType ??= WalletType.leader;
    if (walletType == WalletType.leader) {
      return await leader.makeSaveLeaderWallet(
        pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        mnemonic: mnemonic,
        name: name,
        getEntropy: getEntropy,
        saveSecret: saveSecret,
      );
    } else {
      //WalletType.single
      return await single.makeSaveSingleWallet(
        pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        wif: mnemonic,
        name: name,
        getEntropy: getEntropy,
        saveSecret: saveSecret,
      );
    }
  }

  Future generate() async => await services.wallet.createSave(
      walletType: WalletType.leader,
      cipherUpdate: services.cipher.currentCipherUpdate,
      mnemonic: null);

  Tuple2<Wallet, Secret>? create({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String? secret,
    bool alwaysReturn = false,
    Future<String> Function(String id)? getEntropy,
  }) {
    final entropy = bip39.mnemonicToEntropy(secret ?? bip39.generateMnemonic());
    switch (walletType) {
      case WalletType.leader:
        final wallet = leader.makeLeaderWallet(
          pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          entropy: entropy,
          alwaysReturn: alwaysReturn,
          getEntropy: getEntropy,
        );
        return Tuple2(
            wallet!,
            Secret(
              pubkey: wallet.pubkey,
              secret: entropy,
              secretType: SecretType.entropy,
            ));
      case WalletType.single:
        final wallet = single.makeSingleWallet(
          pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          wif: secret!,
          alwaysReturn: alwaysReturn,
          getEntropy: getEntropy,
        );
        return Tuple2(
            wallet!,
            Secret(
              pubkey: wallet.id,
              secret: secret!,
              secretType: SecretType.wif,
            ));
      default:
        return create(
          walletType: WalletType.leader,
          cipherUpdate: cipherUpdate,
          secret: secret,
          alwaysReturn: alwaysReturn,
          getEntropy: getEntropy,
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
}
