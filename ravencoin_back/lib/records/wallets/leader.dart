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
  final String encryptedEntropy; // deprecated

  LeaderWallet({
    required String id,
    required this.encryptedEntropy,
    bool backedUp = false,
    bool skipHistory = false,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    String? name,
    Uint8List? seed,
    Future<String> Function(String id)? getEntropy,
  }) : super(
          id: id,
          cipherUpdate: cipherUpdate,
          name: name,
          backedUp: backedUp,
          skipHistory: skipHistory,
        ) {
    _seed = seed;
    _getEntropy = getEntropy;
  }

  Uint8List? _seed;
  Future<String> Function(String id)? _getEntropy;

  factory LeaderWallet.from(
    LeaderWallet existing, {
    String? id,
    String? encryptedEntropy,
    bool? backedUp,
    bool? skipHistory,
    CipherUpdate? cipherUpdate,
    String? name,
    Uint8List? seed, // must pass in if you want to save it.
    Future<String> Function(String id)? getEntropy,
  }) =>
      LeaderWallet(
        id: id ?? existing.id,
        encryptedEntropy: encryptedEntropy ?? existing.encryptedEntropy,
        backedUp: backedUp ?? existing.backedUp,
        skipHistory: skipHistory ?? existing.skipHistory,
        cipherUpdate: cipherUpdate ?? existing.cipherUpdate,
        name: name ?? existing.name,
        seed: seed, // can't autopopulate seed because it's async, must pass in.
        getEntropy: getEntropy ?? existing.getEntropy,
      );

  void setSecret(Future<String> Function(String id) getEntropy) =>
      _getEntropy = getEntropy;

  @override
  List<Object?> get props =>
      [id, cipherUpdate, encryptedEntropy, backedUp, skipHistory];

  @override
  String toString() =>
      'LeaderWallet($id, $encryptedEntropy, $cipherUpdate, $backedUp, $skipHistory)';

  @override
  String get encrypted => encryptedEntropy;

  @override
  Future<String> secret([CipherBase? cipher]) async => await mnemonic;

  @override
  Future<ravenwallet.HDWallet> seedWallet(CipherBase cipher,
          {Net net = Net.Main}) async =>
      SeedWallet(await seed, net).wallet;

  @override
  SecretType get secretType => SecretType.mnemonic;

  @override
  WalletType get walletType => WalletType.leader;

  @override
  String get secretTypeToString => secretType.name;

  @override
  String get walletTypeToString => walletType.name;

  String get pubkey => id;

  Future<Uint8List?> get publicKey async =>
      (await services.wallet.leader.getSeedWallet(this))
          .wallet
          .keyPair
          .publicKey;

  Future<String> Function(String id)? get getEntropy => _getEntropy;

  Future<Uint8List> get seed async {
    _seed ??= bip39.mnemonicToSeed(await mnemonic);
    return _seed!;
  }

  Future<String> get mnemonic async => bip39.entropyToMnemonic(await entropy);

  Future<String> get entropy async => hex.decrypt(
      encryptedEntropy == ''
          ? await (_getEntropy ?? (id) async => id)(id)
          : encryptedEntropy,
      cipher!);
}
