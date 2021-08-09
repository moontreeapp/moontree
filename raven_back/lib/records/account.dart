// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'balance.dart';

part 'account.g.dart';

@HiveType(typeId: 1)
class Account with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  String name;

  Account({required this.accountId, required this.name});

  @override
  List<Object> get props => [accountId];

  @override
  String toString() => 'Account($accountId, $name)';
}
