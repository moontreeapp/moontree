import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/lingo/lingo.dart';
import 'package:raven/records/cipher_update.dart';
import 'package:raven/records/net.dart';
import 'package:raven/security/security.dart';
import 'package:ravencoin/ravencoin.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String accountId;

  @HiveField(2)
  final CipherUpdate cipherUpdate;

  @override
  List<Object?> get props => [walletId, accountId];

  Wallet({
    required this.walletId,
    required this.accountId,
    required this.cipherUpdate,
  });

  String get encrypted;

  String secret(Cipher cipher);

  WalletBase seedWallet(Cipher cipher, {Net net = Net.Main});

  String get humanType => 'Wallet';

  String get humanSecretType => 'Secret';

  LingoKey get humanTypeKey => LingoKey.walletType;

  LingoKey get humanSecretTypeKey => LingoKey.walletSecretType;
}
