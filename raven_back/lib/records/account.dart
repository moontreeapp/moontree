// dart run build_runner build
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';
import '../accounts.dart';

part 'account.g.dart';

@HiveType(typeId: 13)
class Account {
  @HiveField(0)
  Uint8List symmetricallyEncryptedSeed;

  @HiveField(1)
  int networkWif;

  @HiveField(2)
  String name;

  Account(this.symmetricallyEncryptedSeed,
      {this.networkWif = /* testnet */ 0xef, this.name = 'Wallet'});

  NetworkType get network => ravencoinNetworks[networkWif]!;

  String get accountId => sha256
      .convert(Accounts.instance.cipher.decrypt(symmetricallyEncryptedSeed))
      .toString();
}
