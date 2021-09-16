import 'package:ravencoin/ravencoin.dart' show KPWallet;
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';

class SingleWalletService extends Service {
  late AccountReservoir accounts;

  SingleWalletService(this.accounts) : super();

  Address toAddress(SingleWallet wallet) {
    var net = accounts.primaryIndex.getOne(wallet.accountId)!.net;
    var seededWallet = KPWallet.fromWIF(wallet.wif);
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: wallet.walletId,
        hdIndex: 0,
        net: net);
  }
}
