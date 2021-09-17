import 'package:raven/utils/cipher.dart';
import 'package:raven/utils/encrypted_entropy.dart';
import 'package:ravencoin/ravencoin.dart' show KPWallet;
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';

class SingleWalletService extends Service {
  late AccountReservoir accounts;

  SingleWalletService(this.accounts) : super();

  Address toAddress(SingleWallet wallet, Cipher cipher) {
    var net = accounts.primaryIndex.getOne(wallet.accountId)!.net;
    var seedWallet =
        KPWallet.fromWIF(EncryptedWIF(wallet.encryptedWIF, cipher).wif);
    return Address(
        scripthash: seedWallet.scripthash,
        address: seedWallet.address!,
        walletId: wallet.walletId,
        hdIndex: 0,
        net: net);
  }
}
