// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven/records/net.dart';

part 'account.g.dart';

@HiveType(typeId: 1)
class Account with EquatableMixin {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  Net net;

  Account({
    required this.id,
    required this.name,
    this.net = Net.Test,
  });

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'Account($id, $name, $net)';
}
