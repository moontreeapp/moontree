// dart run build_runner build
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'net.dart';

part 'wallet.g.dart';

@HiveType(typeId: 0)
class Wallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  bool isHD;

  @HiveField(1)
  Uint8List encrypted; // seed or private key

  @HiveField(2)
  Net net;

  Wallet({required this.isHD, required this.encrypted, this.net = Net.Test});

  @override
  List<Object> get props => [encrypted];

  @override
  String toString() => 'Wallet($net, ${encrypted.take(6).toList()})';
}
