import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/records/cipher_update.dart';
import 'package:raven_back/records/net.dart';
import 'package:raven_back/security/security.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CipherUpdate cipherUpdate;

  @HiveField(2)
  final String name;

  @HiveField(3)
  int highestUsedExternalIndex;

  @HiveField(4)
  int highestSavedExternalIndex;

  @HiveField(5)
  int highestUsedInternalIndex;

  @HiveField(6)
  int highestSavedInternalIndex;

  @override
  List<Object?> get props => [id, cipherUpdate, name];

  Wallet({
    required this.id,
    required this.cipherUpdate,
    String? name,
    this.highestUsedExternalIndex = 0,
    this.highestSavedExternalIndex = 0,
    this.highestUsedInternalIndex = 0,
    this.highestSavedInternalIndex = 0,
  }) : name = name ?? (id.length > 5 ? id.substring(0, 6) : id[0]);

  String get encrypted;

  String secret(CipherBase cipher);

  WalletBase seedWallet(CipherBase cipher, {Net net = Net.Main});

  SecretType get secretType => SecretType.none;

  WalletType get walletType => WalletType.none;

  String get publicKey => id;

  String get secretTypeToString => secretType.enumString;
  String get walletTypeToString => walletType.enumString;
}
