import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:ravencoin/ravencoin.dart';

part 'account_stored.g.dart';

@HiveType(typeId: 13)
class AccountStored {
  @HiveField(0)
  Uint8List symmetricallyEncryptedSeed;

  @HiveField(1)
  int networkWif;

  @HiveField(2)
  String name;

  AccountStored(this.symmetricallyEncryptedSeed,
      {this.networkWif = /* testnet */ 0xef, this.name = 'Wallet'});

  NetworkType get network => ravencoinNetworks[networkWif]!;
}
