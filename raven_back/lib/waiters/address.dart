import 'package:raven/raven.dart';

import 'waiter.dart';

class AddressWaiter extends Waiter {
  void init() {
    listen('addresses.changes', addresses.changes, (Change<Address> change) {
      change.when(
          loaded: (loaded) {},
          added: (added) {
            /// every time we add an address check to see if we need to make more?
            //var address = added.data;
            //if (address.wallet is LeaderWallet) {
            //  var wallet = address.wallet as LeaderWallet;
            //  if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
            //    services.wallet.leader.deriveMoreAddresses(
            //      wallet,
            //      exposures: [address.exposure],
            //    );
            //  }
            //}
          },
          updated: (updated) {},
          removed: (removed) {
            var address = removed.data;
            // could be moved to waiter on transactions...
            vouts.removeAll(address.vouts.map((vout) => vout).toList());
            //vins.removeAll(address.vins.map((vin) => vin).toList()); // no way to join on it...
          });
    });
  }
}
