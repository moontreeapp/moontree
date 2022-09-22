import 'package:hive/hive.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/seed_wallet.dart';

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(7)
  final String encryptedWIF;

  SingleWallet({
    required String id,
    required this.encryptedWIF,
    CipherUpdate cipherUpdate = defaultCipherUpdate,
    bool skipHistory = false,
    String? name,
    Future<String> Function(String id)? getWif,
  }) : super(
          id: id,
          cipherUpdate: cipherUpdate,
          backedUp: true,
          skipHistory: skipHistory,
          name: name,
        ) {
    _getWif = getWif;
  }

  Future<String> Function(String id)? _getWif;

  factory SingleWallet.from(
    SingleWallet existing, {
    String? id,
    String? encryptedWIF,
    CipherUpdate? cipherUpdate,
    bool? skipHistory,
    String? name,
    Future<String> Function(String id)? getWif,
  }) =>
      SingleWallet(
        id: id ?? existing.id,
        encryptedWIF: encryptedWIF ?? existing.encryptedWIF,
        cipherUpdate: cipherUpdate ?? existing.cipherUpdate,
        skipHistory: skipHistory ?? existing.skipHistory,
        name: name ?? existing.name,
        getWif: getWif ?? existing.getWif,
      );

  @override
  List<Object?> get props => [id, cipherUpdate, encryptedWIF, skipHistory];

  @override
  String toString() =>
      'SingleWallet($id, $encryptedWIF, $cipherUpdate, $skipHistory)';

  @override
  String get encrypted => encryptedWIF;

  @override
  Future<String> secret(CipherBase cipher) async =>
      EncryptedWIF(encrypted, cipher).secret;

  @override
  Future<KPWallet> seedWallet(CipherBase cipher, {Net net = Net.Main}) async =>
      SingleSelfWallet(await secret(cipher)).wallet;

  @override
  SecretType get secretType => EncryptedWIF.secretType;

  @override
  WalletType get walletType => WalletType.single;

  @override
  String get secretTypeToString => secretType.name;

  @override
  String get walletTypeToString => walletType.name;

  void setSecret(Future<String> Function(String id) getSecret) =>
      _getWif = getSecret;

  String? get publicKey => services.wallet.single.getKPWallet(this).pubKey;

  Future<String> Function(String id)? get getWif => _getWif;

  Future<KPWallet> get kpWallet async =>
      KPWallet.fromWIF((await wif) ?? '', pros.settings.network);

  Future<String?> get wif async => await (encryptedWIF == ''
      ? _getWif ?? ((_) async => '')
      : (_) async => services.wallet.single.getKPWallet(this).wif)(id);
}
