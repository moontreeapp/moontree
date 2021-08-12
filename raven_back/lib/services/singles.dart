import 'dart:async';

import 'package:ravencoin/ravencoin.dart'
    show KPWallet, ECPair, P2PKH, PaymentData;
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/services/service.dart';

class SinglesService extends Service {
  AccountReservoir accounts;
  SingleWalletReservoir singles;
  AddressReservoir addresses;
  HistoryReservoir histories;
  late StreamSubscription<Change> listener;

  SinglesService(
    this.accounts,
    this.singles,
    this.addresses,
    this.histories,
  ) : super();

  @override
  void init() {
    listener = singles.changes.listen((change) {
      change.when(added: (added) {
        var wallet = added.data;
        addresses.save(deriveAddress(wallet, NodeExposure.External));
        addresses.save(deriveAddress(wallet, NodeExposure.Internal));
      }, updated: (updated) {
        /* moved account */
      }, removed: (removed) {
        addresses.removeAddresses(removed.id as String);
      });
    });
  }

  @override
  void deinit() {
    listener.cancel();
  }

  KPWallet getSingleWallet(SingleWallet wallet, Net net) {
    return KPWallet(
        ECPair.fromPrivateKey(wallet.privateKey,
            network: networks[net]!, compressed: true),
        P2PKH(data: PaymentData(), network: networks[net]!),
        networks[net]!);
  }

  Address deriveAddress(wallet, NodeExposure exposure) {
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
