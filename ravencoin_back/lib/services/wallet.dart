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

  // should return all cipherUpdates
  Set<CipherUpdate> get getAllCipherUpdates =>
      pros.wallets.data.map((wallet) => wallet.cipherUpdate).toSet();

  // should return cipherUpdates that must be used with current password...
  Set<CipherUpdate> get getCurrentCipherUpdates => pros.wallets.data
      .map((wallet) => wallet.cipherUpdate)
      .where((cipherUpdate) =>
          cipherUpdate.passwordId == pros.passwords.maxPasswordId)
      .toSet();

  // should return cipherUpdates that must be used with previous password...
  Set<CipherUpdate> get getPreviousCipherUpdates =>
      pros.passwords.maxPasswordId == null
          ? {}
          : pros.wallets.data
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

  Wallet? create({
    required WalletType walletType,
    required CipherUpdate cipherUpdate,
    required String? secret,
    bool alwaysReturn = false,
  }) =>
      {
        WalletType.leader: () => leader.makeLeaderWallet(
              pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              entropy: secret != null ? bip39.mnemonicToEntropy(secret) : null,
              alwaysReturn: alwaysReturn,
            ),
        WalletType.single: () => single.makeSingleWallet(
              pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
              cipherUpdate: cipherUpdate,
              wif: secret,
              alwaysReturn: alwaysReturn,
            )
      }[walletType]!();

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

  WalletBase getChangeWallet(Wallet wallet) {
    if (wallet is LeaderWallet) {
      return leader.getNextEmptyWallet(wallet);
    }
    if (wallet is SingleWallet) {
      return single.getKPWallet(wallet);
    }
    throw WalletMissing("Wallet '${wallet.id}' has no change wallets");
  }

  String getChangeAddress(Wallet wallet) {
    if (wallet is LeaderWallet) {
      return leader.getNextChangeAddress(wallet);
    }
    if (wallet is SingleWallet) {
      return wallet.addresses.first.address;
    }
    throw WalletMissing("Wallet '${wallet.id}' has no change wallets");
  }

  // new, fast cached way (cache generated and saved during download)
  String getEmptyAddressFromCache(Wallet wallet, {bool random = false}) {
    if (wallet is LeaderWallet) {
      return leader.getNextEmptyAddress(wallet,
          exposure: NodeExposure.External, random: random);
    }
    if (wallet is SingleWallet) {
      return wallet.addresses.first.address;
    }
    throw WalletMissing("Wallet '${wallet.id}' has no change wallets");
  }

  // old, slow reliable way to get an empty wallet
  WalletBase getEmptyWalletFromDatabase(Wallet wallet,
      {exposure = NodeExposure.External}) {
    if (wallet is LeaderWallet) {
      return leader.getNextEmptyWallet(wallet, exposure: NodeExposure.External);
    }
    if (wallet is SingleWallet) {
      return single.getKPWallet(wallet);
    }
    throw WalletMissing("Wallet '${wallet.id}' has no change wallets");
  }

  String getEmptyAddress(
    Wallet wallet, {
    bool random = false,
    bool internal = false,
    String? address,
  }) {
    if (internal) {
      try {
        return address ?? services.wallet.getChangeAddress(wallet);
      } catch (e) {
        return address ??
            services.wallet
                .getEmptyWalletFromDatabase(
                  wallet,
                  exposure: NodeExposure.Internal,
                )
                .address!;
      }
    }
    try {
      return address ??
          services.wallet.getEmptyAddressFromCache(
            wallet,
            random: random,
          );
    } catch (e) {
      return address ??
          services.wallet.getEmptyWalletFromDatabase(wallet).address!;
    }
  }
}
