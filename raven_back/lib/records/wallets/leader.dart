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

  @HiveField(8)
  final bool backedUp;

  LeaderWallet({
    required String id,
    required this.encryptedEntropy,
    this.backedUp = false,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
    List<int>? unusedInternalIndices,
    List<int>? unusedExternalIndices,
    Uint8List? seed,
  }) : super(
          id: id,
          cipherUpdate: cipherUpdate,
          name: name,
        ) {
    this.unusedInternalIndices = unusedInternalIndices ?? [];
    this.unusedExternalIndices = unusedExternalIndices ?? [];
    _seed = seed;
  }

  Uint8List? _seed;

  /// caching optimization
  late List<int> unusedInternalIndices;
  late List<int> unusedExternalIndices;

  factory LeaderWallet.from(
    LeaderWallet existing, {
    String? id,
    String? encryptedEntropy,
    bool? backedUp,
    CipherUpdate? cipherUpdate,
    String? name,
    List<int>? unusedInternalIndices,
    List<int>? unusedExternalIndices,
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
  List<Object?> get props => [id, cipherUpdate, encryptedEntropy, backedUp];

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
  void addUnusedInternal(int hdIndex) => utils.binaryInsert(
        list: unusedInternalIndices,
        value: hdIndex,
      );
  void addUnusedExternal(int hdIndex) => utils.binaryInsert(
        list: unusedExternalIndices,
        value: hdIndex,
      );
  void removeUnusedInternal(int hdIndex) => utils.binaryRemove(
        list: unusedInternalIndices,
        value: hdIndex,
      );
  void removeUnusedExternal(int hdIndex) => utils.binaryRemove(
        list: unusedExternalIndices,
        value: hdIndex,
      );
  Address? getUnusedAddress(NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? unusedInternalAddress
          : unusedExternalAddress;
  Address? getRandomUnusedAddress(NodeExposure exposure) =>
      exposure == NodeExposure.Internal
          ? randomUnusedInternalAddress
          : randomUnusedExternalAddress;

  Address? get unusedInternalAddress => res.addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.Internal, unusedInternalIndices.first);
  Address? get unusedExternalAddress => res.addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.External, unusedExternalIndices.first);

  Address? get randomUnusedInternalAddress => res
      .addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.Internal, unusedInternalIndices.randomChoice);
  Address? get randomUnusedExternalAddress => res
      .addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.External, unusedExternalIndices.randomChoice);
}
