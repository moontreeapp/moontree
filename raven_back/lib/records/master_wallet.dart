// dart run build_runner build
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'net.dart';

part 'master_wallet.g.dart';

@HiveType(typeId: 1)
class MasterWallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  Uint8List encryptedSeed;

  @HiveField(1)
  Net net;

  MasterWallet(this.encryptedSeed, {this.net = Net.Test});

  @override
  List<Object> get props => [encryptedSeed];

  @override
  String toString() => 'MasterWallet($net, ${encryptedSeed.take(6).toList()})';
}
