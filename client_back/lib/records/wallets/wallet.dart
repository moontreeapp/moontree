import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:wallet_utils/wallet_utils.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CipherUpdate cipherUpdate;

  @HiveField(2)
  final String name;

  @HiveField(3)
  bool backedUp;

  @override
  List<Object?> get props => <Object?>[id, cipherUpdate, name, backedUp];

  Wallet({
    required this.id,
    required this.cipherUpdate,
    this.backedUp = false,
    String? name,
  }) : name = name ?? (id.length > 5 ? id.substring(0, 6) : id[0]);

  String get encrypted;

  Future<String> secret(CipherBase cipher);

  // seemingly unused...
  Future<WalletBase> seedWallet(
    CipherBase cipher, {
    Chain chain = Chain.ravencoin,
    Net net = Net.main,
  });

  SecretType get secretType => SecretType.none;
  WalletType get walletType => WalletType.none;

  String get secretTypeToString => secretType.name;
  String get walletTypeToString => walletType.name;
}
