import 'package:raven/raven.dart';
import 'waiter.dart';

class LeaderWaiter extends Waiter {
  Set<LeaderWallet> backlogLeaderWallets = {};

  /// when we derive new addresses we don't really know if they have any value
  /// in them until another waiter realizes theres a new address and starts
  /// downloading the transaction history. In the meantime we might be
  /// triggered to derive addresses again and we might derive the same one...
  Set<Address> addressCache = {};

  void init() {
    subjects.cipherUpdate.stream.listen((CipherUpdate cipherUpdate) {
      // if this cipher update is in the list of wallets missing ciphers...
      // initialize the wallet and remove it from the list of wallets missing ciphers
      backlogLeaderWallets = attemptLeaderWalletAddressDerive(cipherUpdate);
    });

    listen('wallets.batchedChanges', wallets.batchedChanges,
        (List<Change<Wallet>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var wallet = added.data;
              if (wallet is LeaderWallet) {
                if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
                  deriveMoreAddresses(wallet);
                } else {
                  backlogLeaderWallets.add(wallet);
                }
              }
            },
            updated: (updated) {
              /* moved account */
            },
            removed: (removed) {
              // TODO: do we care if this happens? maybe throw an error to track unexpected wallet removal
            });
      });
    });

    listen('vouts.batchedChanges', vouts.batchedChanges,
        (List<Change<Vout>> batchedChanges) {
      batchedChanges.forEach((change) {
        change.when(
            loaded: (loaded) {},
            added: (added) {
              var vout = added.data;
              print('VOUT GOT ${vout.toAddress}, ${vout.address?.address}');
              print(
                  'VOUT GOT ${vout.toAddress}, ${addresses.byAddress.getOne(vout.toAddress)?.address}');
              //print('VOUT GOT2 $vout, ${vout.wallet}');
              //print(
              //    'VOUT GOT3 ${vout.toAddress}, ${addresses.byAddress.getOne(vout.toAddress)}');
              //if (vout.toAddress == 'mvGqVjyz14NLhN6pmopZKCrm44guHRYZY3') {
              //  for (var address in addresses.data) {
              //    print(address);
              //  }
              //}
              // if vout.address corresponds to an address we know has been empty - then make a new one.
              if (vout.wallet is LeaderWallet) {
                var wallet = vout.wallet as LeaderWallet;
                if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) != null) {
                  deriveMoreAddresses(
                    wallet,
                    exposures: [vout.address!.exposure],
                    vout: vout,
                  );
                } else {
                  backlogLeaderWallets.add(wallet);
                }
              } else {
                for (var wallet in wallets.leaders) {
                  if (ciphers.primaryIndex.getOne(wallet.cipherUpdate) !=
                      null) {
                    deriveMoreAddresses(wallet);
                  } else {
                    backlogLeaderWallets.add(wallet);
                  }
                }
              }
            },
            updated: (updated) {},
            removed: (removed) {});
      });
    });
  }

  Set<LeaderWallet> attemptLeaderWalletAddressDerive(
      CipherUpdate cipherUpdate) {
    var ret = <LeaderWallet>{};
    for (var wallet in backlogLeaderWallets) {
      if (wallet.cipherUpdate == cipherUpdate) {
        deriveMoreAddresses(wallet);
      } else {
        ret.add(wallet);
      }
    }
    return ret;
  }

  void deriveMoreAddresses(
    LeaderWallet wallet, {
    List<NodeExposure>? exposures,
    Vout? vout,
  }) {
    exposures = exposures ?? [NodeExposure.External, NodeExposure.Internal];
    var newAddresses = <Address>{};
    for (var exposure in exposures) {
      newAddresses.addAll(services.wallet.leader.maybeDeriveNextAddresses(
        wallet,
        ciphers.primaryIndex.getOne(wallet.cipherUpdate)!.cipher,
        exposure,
        //witnessedHDIndex: vout?.address?.hdIndex ?? 0,
      ));
    }
    addresses.saveAll(newAddresses);
  }
}
