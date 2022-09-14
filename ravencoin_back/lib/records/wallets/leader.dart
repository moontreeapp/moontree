// ignore_for_file: prefer_final_fields

import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_back/utilities/hex.dart' as hex;

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/utilities/seed_wallet.dart';
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
    bool skipHistory = false,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
    Uint8List? seed,
  }) : super(
          id: id,
          cipherUpdate: cipherUpdate,
          name: name,
          backedUp: backedUp,
          skipHistory: skipHistory,
        ) {
    _seed = seed;
  }

  Uint8List? _seed;

  factory LeaderWallet.from(
    LeaderWallet existing, {
    String? id,
    String? encryptedEntropy,
    bool? backedUp,
    bool? skipHistory,
    CipherUpdate? cipherUpdate,
    String? name,
    Uint8List? seed,
  }) =>
      LeaderWallet(
        id: id ?? existing.id,
        encryptedEntropy: encryptedEntropy ?? existing.encryptedEntropy,
        backedUp: backedUp ?? existing.backedUp,
        skipHistory: skipHistory ?? existing.skipHistory,
        cipherUpdate: cipherUpdate ?? existing.cipherUpdate,
        name: name ?? existing.name,
        seed: seed ?? existing.seed,
      );

  @override
  List<Object?> get props =>
      [id, cipherUpdate, encryptedEntropy, backedUp, skipHistory];

  @override
  String toString() =>
      'LeaderWallet($id, $encryptedEntropy, $cipherUpdate, $backedUp, $skipHistory)';

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

  Uint8List? get publicKey =>
      services.wallet.leader.getSeedWallet(this).wallet.keyPair.publicKey;

  Uint8List get seed {
    _seed ??= bip39.mnemonicToSeed(mnemonic);
    return _seed!;
  }

  String get mnemonic => bip39.entropyToMnemonic(entropy);

  String get entropy => hex.decrypt(encryptedEntropy, cipher!);
}
