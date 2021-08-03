// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> leaderWalletIds;

  @HiveField(2)
  List<String> derivedWalletIds;

  @HiveField(3)
  List<String> privateKeyWalletIds;

  Account(this.name, this.leaderWalletIds, this.derivedWalletIds,
      this.privateKeyWalletIds);

  @override
  List<Object> get props => [name];

  @override
  String toString() =>
      'Account($name, $leaderWalletIds, $derivedWalletIds, $privateKeyWalletIds)';
}
