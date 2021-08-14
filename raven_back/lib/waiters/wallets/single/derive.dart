import 'package:ravencoin/ravencoin.dart'
    show ECPair, KPWallet, P2PKH, PaymentData;
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/waiters/waiter.dart';

class SingleWalletWaiter extends Waiter {
  late AccountReservoir accounts;

  SingleWalletWaiter(this.accounts) : super();

  KPWallet getSingleWallet(SingleWallet wallet, Net net) {
    return KPWallet(
        ECPair.fromPrivateKey(wallet.privateKey,
            network: networks[net]!, compressed: true),
        P2PKH(data: PaymentData(), network: networks[net]!),
        networks[net]!);
  }

  Address toAddress(SingleWallet wallet) {
    var net = accounts.get(wallet.accountId)!.net;
    var seededWallet = getSingleWallet(wallet, net);
    return Address(
        scripthash: seededWallet.scripthash,
        address: seededWallet.address!,
        walletId: wallet.id,
        accountId: wallet.accountId,
        hdIndex: 0,
        net: net);
  }
}
