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
  @HiveField(3)
  final String encryptedEntropy;

  @HiveField(4)
  int highestUsedExternalIndex = -1;

  @HiveField(5)
  int highestSavedExternalIndex = -1;

  @HiveField(6)
  int highestUsedInternalIndex = -1;

  @HiveField(7)
  int highestSavedInternalIndex = -1;

  LeaderWallet({
    required String id,
    required this.encryptedEntropy,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
  }) : super(id: id, cipherUpdate: cipherUpdate, name: name);

  Uint8List? _seed;

  /// caching optimization
  //int highestUsedExternalIndex = -1;
  //int highestSavedExternalIndex = -1;
  //int highestUsedInternalIndex = -1;
  //int highestSavedInternalIndex = -1;
  List _unusedInternalIndices = [];
  List _unusedExternalIndices = [];

  @override
  List<Object?> get props => [
        id,
        cipherUpdate,
        encryptedEntropy,
      ];

  @override
  String toString() => 'LeaderWallet($id,  $encryptedEntropy, $cipherUpdate)';

  @override
  String get encrypted => encryptedEntropy;

  @override
  String secret(CipherBase cipher) => mnemonic;

  @override
  ravenwallet.HDWallet seedWallet(CipherBase cipher, {Net net = Net.Main}) =>
      SeedWallet(
        seed,
        net,
      ).wallet;

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

  /// caching optimization
  void addUnusedInternal(int hdIndex) => utils.binaryInsert(
        list: _unusedInternalIndices,
        value: hdIndex,
      );
  void addUnusedExternal(int hdIndex) => utils.binaryInsert(
        list: _unusedExternalIndices,
        value: hdIndex,
      );
  void removeUnusedInternal(int hdIndex) => utils.binaryRemove(
        list: _unusedInternalIndices,
        value: hdIndex,
      );
  void removeUnusedExternal(int hdIndex) => utils.binaryRemove(
        list: _unusedExternalIndices,
        value: hdIndex,
      );
  Address? get unusedInternalAddress => res.addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.Internal, _unusedInternalIndices.first);
  Address? get unusedExternalAddress => res.addresses.byWalletExposureIndex
      .getOne(id, NodeExposure.External, _unusedExternalIndices.first);
}
