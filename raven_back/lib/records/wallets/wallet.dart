import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/utils/cipher.dart';

export 'extended_wallet_base.dart';

abstract class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String accountId;

  @override
  List<Object?> get props => [id, accountId];

  Wallet({required this.id, required this.accountId});

  Cipher get cipher => const NoCipher();

  String get kind => 'Wallet';

  String get secret => '';
}
