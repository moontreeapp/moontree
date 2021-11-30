import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/records/cipher_update.dart';
import 'package:raven_back/records/net.dart';
import 'package:raven_back/security/security.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/utils/enum.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String accountId;

  @HiveField(2)
  final CipherUpdate cipherUpdate;

  @override
  List<Object?> get props => [walletId, accountId, cipherUpdate];

  Wallet({
    required this.walletId,
    required this.accountId,
    required this.cipherUpdate,
  });

  String get encrypted;

  String secret(CipherBase cipher);

  WalletBase seedWallet(CipherBase cipher, {Net net = Net.Main});

  SecretType get secretType => SecretType.none;

  WalletType get walletType => WalletType.none;

  String get publicKey => walletId;

  String get secretTypeToString => describeEnum(secretType);
  String get walletTypeToString => describeEnum(walletType);
}
