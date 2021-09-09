// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart' show NetworkType;

import 'package:raven/records/net.dart';

import '_type_id.dart';
part 'account.g.dart';

@HiveType(typeId: TypeId.Account)
class Account with EquatableMixin {
  @HiveField(0)
  String accountId;

  @HiveField(1)
  String name;

  @HiveField(2)
  Net net;

  Account({
    required this.accountId,
    required this.name,
    this.net = Net.Test,
  });

  @override
  List<Object> get props => [accountId, name, net];

  @override
  String toString() => 'Account($accountId, $name, $net)';

  NetworkType get network => networks[net]!;
}
