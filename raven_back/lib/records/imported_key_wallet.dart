// dart run build_runner build
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'net.dart';

part 'imported_key_wallet.g.dart';

@HiveType(typeId: 8)
class ImportedPrivateKeyWallet with HiveObjectMixin, EquatableMixin {
  @HiveField(0)
  Uint8List encryptedPrivateKey;

  @HiveField(1)
  Net net;

  ImportedPrivateKeyWallet(this.encryptedPrivateKey, {this.net = Net.Test});

  @override
  List<Object> get props => [encryptedPrivateKey];

  @override
  String toString() =>
      'ImportedPrivateKeyWallet($net, ${encryptedPrivateKey.take(6).toList()})';
}
