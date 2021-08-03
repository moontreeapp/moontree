// dart run build_runner build
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'net.dart';

part 'leader_wallet.g.dart';

@HiveType(typeId: 6)
class LeaderWallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  Uint8List encryptedSeed;

  @HiveField(1)
  Net net;

  LeaderWallet(this.encryptedSeed, {this.net = Net.Test});

  @override
  List<Object> get props => [encryptedSeed];

  @override
  String toString() => 'LeaderWallet($net, ${encryptedSeed.take(6).toList()})';
}
