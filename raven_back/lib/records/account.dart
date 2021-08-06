// dart run build_runner build
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 1)
class Account with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  String name;

  /// presumed
  //@HiveField(1)
  //Map<String, dynamic> settings;

  /// presumed
  //@HiveField(2)
  //Map<String, dynamic> metadata;

  Account({required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'Account($name)';
}
