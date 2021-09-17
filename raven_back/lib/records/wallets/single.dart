import 'package:hive/hive.dart';
import 'wallet.dart';

import '../_type_id.dart';

part 'single.g.dart';

@HiveType(typeId: TypeId.SingleWallet)
class SingleWallet extends Wallet {
  @HiveField(3)
  final String encryptedWIF;

  SingleWallet({
    required String walletId,
    required String accountId,
    required this.encryptedWIF,
  }) : super(walletId: walletId, accountId: accountId);

  @override
  String toString() => 'SingleWallet($walletId, $accountId, $encryptedWIF)';

  //@override
  ////String get secret => utf8.decode(privateKey);
  //String get secret => wif;
  //
  //String get wif => utf8
  //    .decode(cipher.decrypt(Uint8List.fromList(utf8.encode(encryptedWIF))));
  //
  ///// Invalid argument(s): Not enough data
  ///// package:ravencoin/src/payments/p2pkh.dart 43:7  P2PKH._init
  ///// package:ravencoin/src/payments/p2pkh.dart 17:5  new P2PKH
  ////static String getWalletIdFromPrivateKey(Uint8List encryptedPrivateKey,
  ////        {bool compressed = true}) =>
  ////    KPWallet(
  ////            ECPair.fromPrivateKey(
  ////              NoCipher().decrypt(encryptedPrivateKey),
  ////              network: networks[Net.Test]!,
  ////              compressed: compressed,
  ////            ),
  ////            P2PKH(data: PaymentData(), network: networks[Net.Test]!),
  ////            networks[Net.Test])
  ////        .pubKey!;
  //
  //static String getWalletIdFromWIF(String wif) => KPWallet.fromWIF(wif).pubKey!;
  //
  //static String encryptWIF(wif) =>
  //    utf8.decode(NoCipher().encrypt(Uint8List.fromList(utf8.encode(wif))));
}
