import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/cipher_type.dart';
import 'package:raven/utils/cipher.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String walletId;

  @HiveField(1)
  final String accountId;

  @HiveField(2)
  final CipherType cipherType;

  @override
  List<Object?> get props => [walletId, accountId];

  Wallet(
      {required this.walletId,
      required this.accountId,
      this.cipherType = CipherType.AESCipher});

  // TODO: can this be part of a join?
  // String get secret => '';
}
