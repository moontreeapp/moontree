// ignore_for_file: prefer_final_fields

import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart' as ravenwallet;
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_back/utilities/seed_wallet.dart';

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

  factory LeaderWallet.empty() => LeaderWallet(id: '', encryptedEntropy: '');

  void setSecret(Future<String> Function(String id) getEntropy) =>
      _getEntropy = getEntropy;

  @override
  List<Object?> get props => <Object?>[
        id,
        cipherUpdate,
        encryptedEntropy,
        backedUp,
        skipHistory,
        name
      ];

  @override
  String toString() =>
      'LeaderWallet($id, $encryptedEntropy, $cipherUpdate, $backedUp, $skipHistory, $name)';

  @override
  String get encrypted => encryptedEntropy;

  Future<String> get encryptedSecret async => encryptedEntropy == ''
      ? await (_getEntropy ?? (String id) async => id)(id)
      : encryptedEntropy;

  @override
  Future<String> secret([CipherBase? cipher]) async => mnemonic;

  @override
  Future<ravenwallet.HDWallet> seedWallet(
    CipherBase cipher, {
    Chain chain = Chain.ravencoin,
    Net net = Net.main,
  }) async =>
      SeedWallet(await seed, ChainNet(chain, net)).wallet;

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

  Future<String> get entropy async => decrypt(await encryptedSecret, cipher!);
}
