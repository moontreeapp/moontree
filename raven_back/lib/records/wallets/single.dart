// dart run build_runner build
import 'dart:convert';
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:raven/utils/cipher.dart';
import 'wallet.dart';
//import 'package:raven/records/net.dart';
import 'package:ravencoin/ravencoin.dart'
    show KPWallet; //, ECPair,  P2PKH, PaymentData;

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(2)
  final String encryptedWIF;

  SingleWallet({
    required accountId,
    required this.encryptedWIF,
    String? walletId,
  }) : super(
            walletId: walletId ??
                getWalletIdFromWIF(utf8.decode(NoCipher()
                    .decrypt(Uint8List.fromList(utf8.encode(encryptedWIF))))),
            accountId: accountId);

  @override
  String toString() => 'SingleWallet($walletId, $accountId, $encryptedWIF)';

  @override
  String get kind => 'Private Key Wallet';

  @override
  //String get secret => utf8.decode(privateKey);
  String get secret => wif;

  String get wif => utf8
      .decode(cipher.decrypt(Uint8List.fromList(utf8.encode(encryptedWIF))));

  /// Invalid argument(s): Not enough data
  /// package:ravencoin/src/payments/p2pkh.dart 43:7  P2PKH._init
  /// package:ravencoin/src/payments/p2pkh.dart 17:5  new P2PKH
  //static String getWalletIdFromPrivateKey(Uint8List encryptedPrivateKey,
  //        {bool compressed = true}) =>
  //    KPWallet(
  //            ECPair.fromPrivateKey(
  //              NoCipher().decrypt(encryptedPrivateKey),
  //              network: networks[Net.Test]!,
  //              compressed: compressed,
  //            ),
  //            P2PKH(data: PaymentData(), network: networks[Net.Test]!),
  //            networks[Net.Test])
  //        .pubKey!;

  static String getWalletIdFromWIF(String wif) => KPWallet.fromWIF(wif).pubKey!;

  static String encryptWIF(wif) =>
      utf8.decode(NoCipher().encrypt(Uint8List.fromList(utf8.encode(wif))));
}
