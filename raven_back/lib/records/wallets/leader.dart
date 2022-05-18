// ignore_for_file: prefer_final_fields

import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven_back/utilities/hex.dart' as hex;

import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/utilities/seed_wallet.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravenwallet;

import '../_type_id.dart';

part 'leader.g.dart';

@HiveType(typeId: TypeId.LeaderWallet)
class LeaderWallet extends Wallet {
  @HiveField(7)
  final String encryptedEntropy;

  LeaderWallet({
    required String id,
    required this.encryptedEntropy,
    bool backedUp = false,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
    Set<int>? unusedInternalIndices,
    Set<int>? unusedExternalIndices,
    Uint8List? seed,
  }) : super(
          id: id,
          cipherUpdate: cipherUpdate,
          name: name,
          backedUp: backedUp,
        ) {
    this.unusedInternalIndices = unusedInternalIndices ?? {};
    this.unusedExternalIndices = unusedExternalIndices ?? {};
    _seed = seed;
  }

  Uint8List? _seed;

  /// caching optimization
  late Set<int> unusedInternalIndices;
  late Set<int> unusedExternalIndices;

  factory LeaderWallet.from(
    LeaderWallet existing, {
    String? id,
    String? encryptedEntropy,
    bool? backedUp,
    CipherUpdate? cipherUpdate,
    String? name,
    Set<int>? unusedInternalIndices,
    Set<int>? unusedExternalIndices,
    Uint8List? seed,
  }) =>
      LeaderWallet(
        id: id ?? existing.id,
        encryptedEntropy: encryptedEntropy ?? existing.encryptedEntropy,
        backedUp: backedUp ?? existing.backedUp,
        cipherUpdate: cipherUpdate ?? existing.cipherUpdate,
        name: name ?? existing.name,
        unusedInternalIndices:
            unusedInternalIndices ?? existing.unusedInternalIndices,
        unusedExternalIndices:
            unusedExternalIndices ?? existing.unusedExternalIndices,
        seed: seed ?? existing.seed,
      );

  @override
  List<Object?> get props => [id, cipherUpdate, encryptedEntropy];

  @override
  String toString() =>
      'LeaderWallet($id, $encryptedEntropy, $cipherUpdate, $backedUp)';

  @override
  String get encrypted => encryptedEntropy;

  @override
  String secret(CipherBase cipher) => mnemonic;

  @override
  ravenwallet.HDWallet seedWallet(CipherBase cipher, {Net net = Net.Main}) =>
      SeedWallet(seed, net).wallet;

  @override
  SecretType get secretType => SecretType.mnemonic;

  @override
  WalletType get walletType => WalletType.leader;

  @override
  String get secretTypeToString => secretType.enumString;

  @override
  String get walletTypeToString => walletType.enumString;

  Uint8List get seed {
    _seed ??= bip39.mnemonicToSeed(mnemonic);
    return _seed!;
  }

  String get mnemonic => bip39.entropyToMnemonic(entropy);

  String get entropy => hex.decrypt(encryptedEntropy, cipher!);

  /// caching optimization ///
  void addUnused(int hdIndex, NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? addUnusedInternal(hdIndex)
          : addUnusedExternal(hdIndex);
  void removeUnused(int hdIndex, NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? removeUnusedInternal(hdIndex)
          : removeUnusedExternal(hdIndex);

  void addUnusedInternal(int hdIndex) => unusedInternalIndices.add(hdIndex);
  void addUnusedExternal(int hdIndex) => unusedExternalIndices.add(hdIndex);
  void removeUnusedInternal(int hdIndex) =>
      unusedInternalIndices.remove(hdIndex);
  void removeUnusedExternal(int hdIndex) =>
      unusedExternalIndices.remove(hdIndex);
  Address? getUnusedAddress(NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? unusedInternalAddress
          : unusedExternalAddress;
  Address? getRandomUnusedAddress(NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? randomUnusedInternalAddress
          : randomUnusedExternalAddress;

  Address? get unusedInternalAddress {
    return res.addresses.byWalletExposureIndex
        .getOne(id, NodeExposure.Internal, unusedInternalIndices.min);
  }

  Address? get unusedExternalAddress => res.addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.External, unusedExternalIndices.min);

  Address? get randomUnusedInternalAddress => res
      .addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.Internal, unusedInternalIndices.randomChoice);
  Address? get randomUnusedExternalAddress => res
      .addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.External, unusedExternalIndices.randomChoice);
}
