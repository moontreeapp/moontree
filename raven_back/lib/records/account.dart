// dart run build_runner build
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'net.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  Uint8List encryptedSeed;

  @HiveField(1)
  Net net;

  @HiveField(2)
  String name;

  Account(this.encryptedSeed, {this.net = Net.Test, this.name = 'Wallet'});

  @override
  List<Object> get props => [encryptedSeed];

  @override
  String toString() =>
      'Account($name, $net, ${encryptedSeed.take(6).toList()})';
}
