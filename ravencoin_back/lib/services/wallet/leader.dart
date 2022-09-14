// ignore_for_file: omit_local_variable_types

import 'package:equatable/equatable.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show HDWallet;
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_back/utilities/hex.dart' as hex;

import 'package:ravencoin_back/utilities/seed_wallet.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final int requiredGap = 20;
  Set backlog = <LeaderWallet>{};
  bool newLeaderProcessRunning = false;

  bool gapSatisfied(LeaderWallet leader, [NodeExposure? exposure]) =>
      exposure != null
          ? leader.gapAddresses(exposure).length >= requiredGap
          : gapSatisfied(leader, NodeExposure.External) &&
              gapSatisfied(leader, NodeExposure.Internal);

  Future<void> handleDeriveAddress({
    required LeaderWallet leader,
    NodeExposure? exposure,
  }) async {
    if (pros.ciphers.primaryIndex.getOne(leader.cipherUpdate) != null) {
      await services.wallet.leader.deriveMoreAddresses(
        leader,
        exposure == null ? null : [exposure],
      );
    } else {
      services.wallet.leader.backlog.add(leader);
    }
  }

  Future<void> backedUp(LeaderWallet leader) async {
    await pros.wallets.save(LeaderWallet.from(leader, backedUp: true));
  }

  /// we have a linear process for handling new leaders (those w/o addresses):
  ///   Derive, get histories by address in batch, derive until done.
  ///   Get unspents in batch.
  ///   Build balances.
  ///   Get transactions in batch by address, or by arbitrary batch number.
  ///   Get dangling transactions
  ///   Get status of addresses, save
  ///   Save addresses - this will trigger the general case, but since we've
  ///     already saved the most recent status nothing will happen.
  Future<void> newLeaderProcess(LeaderWallet leader) async {
    newLeaderProcessRunning = true;
    streams.client.busy.add(true);
    streams.client.activity.add(ActivityMessage(
        active: true,
        title: 'Syncing with the network',
        message: 'Downloading your balances...'));
    await deriveMoreAddresses(leader);
  }

  Address deriveNextAddress(LeaderWallet wallet, NodeExposure exposure) {
    final hdIndex = wallet.highestIndexOf(exposure) + 1;
    final subwallet = getSubWallet(wallet, hdIndex, exposure);
    return Address(
        id: subwallet.scripthash,
        address: subwallet.address!,
        walletId: wallet.id,
        hdIndex: hdIndex,
        exposure: exposure,
        net: pros.settings.net);
  }

  SeedWallet getSeedWallet(LeaderWallet wallet) {
    return SeedWallet(wallet.seed, pros.settings.net);
  }

  HDWallet getSubWallet(
    LeaderWallet wallet,
    int hdIndex,
    NodeExposure exposure,
  ) =>
      getSeedWallet(wallet).subwallet(hdIndex, exposure: exposure);

  HDWallet getSubWalletFromAddress(Address address) =>
      getSeedWallet(address.wallet as LeaderWallet)
          .subwallet(address.hdIndex, exposure: address.exposure);

  Future<LeaderWallet> generate() async {
    final cipherUpdate = services.cipher.currentCipherUpdate;
    final leaderWallet = makeLeaderWallet(
        pros.ciphers.primaryIndex.getOne(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        entropy: null,
        name: null,
        alwaysReturn: true);
    await pros.wallets.save(leaderWallet!);
    return leaderWallet;
  }

  LeaderWallet? makeLeaderWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? entropy,
    bool alwaysReturn = false,
    String? name,
  }) {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    final mnemonic = bip39.entropyToMnemonic(entropy);
    final seed = bip39.mnemonicToSeed(mnemonic);
    final newId = HDWallet.fromSeed(seed).pubKey;
    final encrypted_entropy = hex.encrypt(entropy, cipher);

    var existingWallet = pros.wallets.primaryIndex.getOne(newId);
    if (existingWallet == null) {
      return LeaderWallet(
          id: newId,
          encryptedEntropy: encrypted_entropy,
          cipherUpdate: cipherUpdate,
          name: name ?? pros.wallets.nextWalletName);
    }
    if (alwaysReturn) return existingWallet as LeaderWallet;
    return null;
  }

  void makeFirstWallet(Cipher currentCipher) {
    if (pros.wallets.isEmpty) {
      makeSaveLeaderWallet(
        currentCipher.cipher,
        cipherUpdate: currentCipher.cipherUpdate,
      );
    }
  }

  Future<void> makeSaveLeaderWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? mnemonic,
    String? name,
  }) async {
    var leaderWallet = makeLeaderWallet(
      cipher,
      cipherUpdate: cipherUpdate,
      entropy: mnemonic != null ? bip39.mnemonicToEntropy(mnemonic) : null,
      name: name,
    );
    if (leaderWallet != null) {
      await pros.wallets.save(leaderWallet);
    }
  }

  /// deriveMoreAddresses also updates the cache we keep of highest saved
  /// addresses for each wallet-exposure. It does so after addresses are
  /// actually saved. the reason for this is that if we update the count to
  /// be higher than the number of addresses actually saved, we'll enter an
  /// infinite loop.
  Future<void> deriveMoreAddresses(
    LeaderWallet wallet, [
    List<NodeExposure>? exposures,
  ]) async {
    exposures = exposures ?? [NodeExposure.External, NodeExposure.Internal];
    var newAddresses = <Address>{};
    for (var exposure in exposures) {
      newAddresses.add(deriveNextAddress(
        wallet,
        exposure,
      ));
    }
    await pros.addresses.saveAll(newAddresses);
  }
}

class LeaderExposureKey with EquatableMixin {
  LeaderWallet leader;
  NodeExposure exposure;

  LeaderExposureKey(this.leader, this.exposure);

  String get key => produceKey(leader.id, exposure);
  static String produceKey(String walletId, NodeExposure exposure) =>
      walletId + exposure.enumString;

  @override
  List<Object> get props => [leader, exposure];

  @override
  String toString() => 'LeaderExposureKey($leader, $exposure)';
}

class LeaderExposureIndex {
  int saved = 0;
  int used = 0;

  LeaderExposureIndex({this.saved = -1, this.used = -1});

  int get currentGap => saved - used;

  void updateSaved(int value) => saved = value > saved ? value : saved;
  void updateUsed(int value) => used = value > used ? value : used;
  void updateSavedPlus(int value) => saved = saved + value;
  void updateUsedPlus(int value) => used = used + value;
}
