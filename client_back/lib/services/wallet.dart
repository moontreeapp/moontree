import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet_utils/src/wallets/hd_wallet.dart';
import 'package:wallet_utils/wallet_utils.dart' show ECPair;

import 'package:client_back/client_back.dart';
import 'package:client_back/utilities/seed_wallet.dart';
import 'package:client_back/services/wallet/leader.dart';
import 'package:client_back/services/wallet/single.dart';
import 'package:client_back/services/wallet/export.dart';
import 'package:client_back/services/wallet/import.dart';
import 'package:client_back/services/wallet/constants.dart';

class WalletService {
  final LeaderWalletService leader = LeaderWalletService();
  final SingleWalletService single = SingleWalletService();
  final ExportWalletService export = ExportWalletService();
  final ImportWalletService import = ImportWalletService();

  Wallet get currentWallet =>
      pros.wallets.primaryIndex.getOne(pros.settings.currentWalletId)!;

  // should return all cipherUpdates
  Set<CipherUpdate> get getAllCipherUpdates =>
      pros.wallets.records.map((Wallet wallet) => wallet.cipherUpdate).toSet();

  // should return cipherUpdates that must be used with current password...
  Set<CipherUpdate> get getCurrentCipherUpdates => pros.wallets.records
      .map((Wallet wallet) => wallet.cipherUpdate)
      .where((CipherUpdate cipherUpdate) =>
          cipherUpdate.passwordId == pros.passwords.maxPasswordId)
      .toSet();

  // should return cipherUpdates that must be used with previous password...
  Set<CipherUpdate> get getPreviousCipherUpdates =>
      pros.passwords.maxPasswordId == null
          ? <CipherUpdate>{}
          : pros.wallets.records
              .map((Wallet wallet) => wallet.cipherUpdate)
              .where((CipherUpdate cipherUpdate) =>
                  cipherUpdate.cipherType != CipherType.none &&
                  cipherUpdate.passwordId! < pros.passwords.maxPasswordId!)
              .toSet();

  /// returns a pubkey, secret
  Future<Wallet?> createSave({
    WalletType? walletType,
    CipherUpdate? cipherUpdate,
    String? mnemonic,
    String? name,
    bool backedUp = false,
    Future<String> Function(String id)? getSecret,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    cipherUpdate ??= services.cipher.currentCipherUpdate;
    walletType ??= WalletType.leader;
    if (walletType == WalletType.leader) {
      return leader.makeSaveLeaderWallet(
        pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        mnemonic: mnemonic,
        name: name,
        backedUp: backedUp,
        getEntropy: getSecret,
        saveSecret: saveSecret,
      );
    } else {
      //WalletType.single
      return single.makeSaveSingleWallet(
        pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        wif: mnemonic,
        name: name,
        getWif: getSecret,
        saveSecret: saveSecret,
      );
    }
  }

  Future<Wallet?> generate() async => services.wallet.createSave(
      walletType: WalletType.leader,
      cipherUpdate: services.cipher.currentCipherUpdate);

  Future<Wallet?> create({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String? secret,
    String? name,
    bool alwaysReturn = false,
    Future<String> Function(String id)? getSecret,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    switch (walletType) {
      case WalletType.leader:
        return leader.makeLeaderWallet(
          pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          entropy: bip39.mnemonicToEntropy(secret ?? bip39.generateMnemonic()),
          name: name,
          alwaysReturn: alwaysReturn,
          getEntropy: getSecret,
          saveSecret: saveSecret,
        );
      case WalletType.single:
        return single.makeSingleWallet(
          pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
          cipherUpdate: cipherUpdate,
          wif: secret,
          name: name,
          alwaysReturn: alwaysReturn,
          getWif: getSecret,
          saveSecret: saveSecret,
        );
      case WalletType.none:
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
    final Wallet? wallet = address.wallet;
    if (wallet is LeaderWallet) {
      final SeedWallet seedWallet =
          await services.wallet.leader.getSeedWallet(wallet);
      final HDWallet hdWallet =
          seedWallet.subwallet(address.index, exposure: address.exposure);
      return hdWallet.keyPair;
    } else if (wallet is SingleWallet) {
      //final KPWallet kpWallet = services.wallet.single.getKPWallet(wallet);
      //return kpWallet.keyPair;
      return (await wallet.kpWallet).keyPair;
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
      address ??
      wallet
          .minimumEmptyAddress(exposure)
          .address(pros.settings.chain, pros.settings.net); // all
  //address ?? wallet.firstEmptyInGap(exposure).address; // gap only
  /// actaully we should fill all the gaps first according to bip44 spec
}
