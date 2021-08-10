// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import 'balance.dart';

part 'account.g.dart';

@HiveType(typeId: 1)
class Account with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  Account({required this.id, required this.name});

  @override
  List<Object> get props => [id];

  @override
  String toString() => 'Account($id, $name)';
}
