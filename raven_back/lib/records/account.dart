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
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Net net;

  /// linked-list to next account
  ///   I only have to make sure the linked address is not itself
  ///   and not the primary one, which is always where I start
  //@HiveField(3)
  //String uiNextAccount;
  /// easier as a list in settings...
  /// should this be a setting?... ''

  Account({
    required this.id,
    required this.name,
    this.net = Net.Test,
  });

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'Account($id, $name, $net)';

  NetworkType get network => networks[net]!;
}
