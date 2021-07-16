import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:hive/hive.dart';

import '../network_params.dart';
import '../raven_networks.dart';
import '../cipher.dart';

part 'account_stored.g.dart';

Cipher cipher = Cipher(defaultInitializationVector);

@HiveType(typeId: 13)
class AccountStored {
  @HiveField(0)
  Uint8List symmetricallyEncryptedSeed;

  @HiveField(1)
  NetworkParams? params;

  @HiveField(2)
  String name;

  @HiveField(3)
  String accountId;

  Uint8List get seed => cipher.decrypt(symmetricallyEncryptedSeed);

  AccountStored(this.symmetricallyEncryptedSeed,
      {networkParams, this.name = 'First Wallet'})
      : params = networkParams ?? ravencoinTestnet,
        accountId = sha256
            .convert(cipher.decrypt(symmetricallyEncryptedSeed))
            .toString();
}
