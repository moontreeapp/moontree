// ignore_for_file: omit_local_variable_types

import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' show HDWallet;
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_back/utilities/seed_wallet.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

// derives addresses for leaderwallets
// returns any that it can't find a cipher for
class LeaderWalletService {
  final int requiredGap = 20;
  Set<LeaderWallet> backlog = <LeaderWallet>{};
  bool newLeaderProcessRunning = false;

  bool gapSatisfied(LeaderWallet leader, [NodeExposure? exposure]) =>
      exposure != null
          ? leader.gapAddresses(exposure).length >= requiredGap
          : gapSatisfied(leader, NodeExposure.external) &&
              gapSatisfied(leader, NodeExposure.internal);

  Future<void> handleDeriveAddress({
    required LeaderWallet leader,
    NodeExposure? exposure,
  }) async {
    if (pros.ciphers.primaryIndex.getOneByCipherUpdate(leader.cipherUpdate) !=
        null) {
      await services.wallet.leader.deriveMoreAddresses(
        leader,
        exposure == null ? null : <NodeExposure>[exposure],
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

  Future<Address> deriveNextAddress(
    LeaderWallet wallet,
    NodeExposure exposure,
  ) async =>
      deriveAddressByIndex(
          wallet: wallet,
          exposure: exposure,
          hdIndex: wallet.highestIndexOf(exposure) + 1);

  Future<Address> deriveAddressByIndex({
    required LeaderWallet wallet,
    required NodeExposure exposure,
    required int hdIndex,
  }) async {
    final HDWallet subwallet = await getSubWallet(wallet, hdIndex, exposure);
    return Address(
        scripthash: subwallet.scripthash,
        address: subwallet.address!,
        walletId: wallet.id,
        hdIndex: hdIndex,
        exposure: exposure,
        chain: pros.settings.chain,
        net: pros.settings.net);
  }

  Future<SeedWallet> getSeedWallet(LeaderWallet wallet) async => SeedWallet(
        await wallet.seed,
        pros.settings.chain,
        pros.settings.net,
      );

  Future<HDWallet> getSubWallet(
    LeaderWallet wallet,
    int hdIndex,
    NodeExposure exposure,
  ) async =>
      (await getSeedWallet(wallet)).subwallet(hdIndex, exposure: exposure);

  Future<HDWallet> getSubWalletFromAddress(Address address) async =>
      (await getSeedWallet(address.wallet! as LeaderWallet))
          .subwallet(address.hdIndex, exposure: address.exposure);

  Future<LeaderWallet> generate() async {
    final CipherUpdate cipherUpdate = services.cipher.currentCipherUpdate;
    final LeaderWallet? leaderWallet = await makeLeaderWallet(
        pros.ciphers.primaryIndex.getOneByCipherUpdate(cipherUpdate)!.cipher,
        cipherUpdate: cipherUpdate,
        alwaysReturn: true);
    await pros.wallets.save(leaderWallet!);
    return leaderWallet;
  }

  Future<LeaderWallet?> makeLeaderWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? entropy,
    bool alwaysReturn = false,
    String? name,
    Future<String> Function(String id)? getEntropy,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    entropy = entropy ?? bip39.mnemonicToEntropy(bip39.generateMnemonic());
    final String mnemonic = bip39.entropyToMnemonic(entropy);
    final Uint8List seed = bip39.mnemonicToSeed(mnemonic);
    final String newId = HDWallet.fromSeed(seed).pubKey;
    final String encryptedEntropy = encrypt(entropy, cipher); // here's how

    final Wallet? existingWallet = pros.wallets.primaryIndex.getOne(newId);
    if (existingWallet == null) {
      // save encryptedEntropy here!
      if (saveSecret != null) {
        await saveSecret(Secret(
          pubkey: newId,
          secret: encryptedEntropy,
          secretType: SecretType.encryptedEntropy,
        ));
      }
      return LeaderWallet(
        id: newId,
        encryptedEntropy: '',
        cipherUpdate: cipherUpdate,
        name: name ?? pros.wallets.nextWalletName,
        getEntropy: getEntropy,
      );
    }
    if (alwaysReturn) {
      return existingWallet as LeaderWallet;
    }
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

  Future<LeaderWallet?> makeSaveLeaderWallet(
    CipherBase cipher, {
    required CipherUpdate cipherUpdate,
    String? mnemonic,
    String? name,
    Future<String> Function(String id)? getEntropy,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    final String secret =
        bip39.mnemonicToEntropy(mnemonic ?? bip39.generateMnemonic());
    final LeaderWallet? leaderWallet = await makeLeaderWallet(
      cipher,
      cipherUpdate: cipherUpdate,
      entropy: secret,
      name: name,
      getEntropy: getEntropy,
      saveSecret: saveSecret,
    );
    if (leaderWallet != null) {
      await pros.wallets.save(leaderWallet);
      return leaderWallet;
    }
    return null;
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
    exposures = exposures ??
        <NodeExposure>[NodeExposure.external, NodeExposure.internal];
    final Set<Address> newAddresses = <Address>{};
    for (final NodeExposure exposure in exposures) {
      newAddresses.add(await deriveNextAddress(
        wallet,
        exposure,
      ));
    }
    await pros.addresses.saveAll(newAddresses);
  }

  Future<void> deriveMoreAddressByIndex(
    LeaderWallet wallet, {
    required int highestIndex,
    List<NodeExposure>? exposures,
  }) async {
    if (pros.ciphers.primaryIndex.getOneByCipherUpdate(wallet.cipherUpdate) !=
        null) {
      exposures = exposures ??
          <NodeExposure>[NodeExposure.external, NodeExposure.internal];
      final Set<Address> newAddresses = <Address>{};
      for (final NodeExposure exposure in exposures) {
        for (final int hdIndex in range(highestIndex)) {
          newAddresses.add(await deriveAddressByIndex(
            wallet: wallet,
            exposure: exposure,
            hdIndex: hdIndex,
          ));
        }
      }
      await pros.addresses.saveAll(newAddresses);
    } else {
      services.wallet.leader.backlog.add(wallet);
    }
  }
}

class LeaderExposureKey with EquatableMixin {
  LeaderExposureKey(this.leader, this.exposure);
  LeaderWallet leader;
  NodeExposure exposure;

  String get key => produceKey(leader.id, exposure);
  static String produceKey(String walletId, NodeExposure exposure) =>
      walletId + exposure.name;

  @override
  List<Object> get props => <Object>[leader, exposure];

  @override
  String toString() => 'LeaderExposureKey($leader, $exposure)';
}

class LeaderExposureIndex {
  LeaderExposureIndex({this.saved = -1, this.used = -1});
  int saved = 0;
  int used = 0;

  int get currentGap => saved - used;

  void updateSaved(int value) => saved = value > saved ? value : saved;
  void updateUsed(int value) => used = value > used ? value : used;
  void updateSavedPlus(int value) => saved = saved + value;
  void updateUsedPlus(int value) => used = used + value;
}
