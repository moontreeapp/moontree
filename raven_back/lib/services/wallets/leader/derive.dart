import 'package:ravencoin/ravencoin.dart' show HDWallet;
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/utils/derivation_path.dart';
import 'package:raven/services/service.dart';

// derives addresses for leaderwallets
class LeaderWalletDerivationService extends Service {
  late final AccountReservoir accounts;
  late final WalletReservoir wallets;
  late final AddressReservoir addresses;
  late final HistoryReservoir histories;

  LeaderWalletDerivationService(
    this.accounts,
    this.wallets,
    this.addresses,
    this.histories,
  ) : super();

  /// [Address(walletid=0...),]
  void maybeDeriveNewAddresses(List<Address> changedAddresses) async {
    for (var address in changedAddresses) {
      var leaderWallet =
          wallets.primaryIndex.getOne(address.walletId)! as LeaderWallet;
      maybeSaveNewAddress(leaderWallet, NodeExposure.Internal);
      maybeSaveNewAddress(leaderWallet, NodeExposure.External);
    }
  }

  void maybeSaveNewAddress(LeaderWallet leaderWallet, NodeExposure exposure) {
    var newAddress = maybeDeriveNextAddress(leaderWallet, exposure);
    if (newAddress != null) {
      addresses.save(newAddress);
    }
  }

  /// this function is used to determin if we need to derive new addresses
  /// based upon the idea that we want to retain a gap of empty histories
  Address? maybeDeriveNextAddress(
    LeaderWallet leaderWallet,
    NodeExposure exposure,
  ) {
    var gap = 0;
    var exposureAddresses =
        addresses.byWalletExposure.getAll(leaderWallet.id, exposure);
    for (var exposureAddress in exposureAddresses) {
      gap = gap +
          (histories.byScripthash.getAll(exposureAddress.scripthash).isEmpty
              ? 1
              : 0);
    }
    if (gap < 10) {
      return deriveAddress(leaderWallet, exposureAddresses.length, exposure);
    }
  }

  Address deriveAddress(
    LeaderWallet wallet,
    int hdIndex,
    NodeExposure exposure,
  ) {
    var net = accounts.primaryIndex.getOne(wallet.accountId)!.net;
    return wallet.deriveAddress(net, hdIndex, exposure);
  }

  void deriveFirstAddressAndSave(LeaderWallet wallet) {
    addresses.save(deriveAddress(wallet, 0, NodeExposure.Internal));
    addresses.save(deriveAddress(wallet, 0, NodeExposure.External));
  }

  /// returns the next internal or external node missing a history
  HDWallet getNextEmptyWallet(
    String walletId, [
    NodeExposure exposure = NodeExposure.Internal,
  ]) {
    // ensure valid exposure
    exposure = exposure == NodeExposure.Internal
        ? NodeExposure.Internal
        : NodeExposure.External;
    var leaderWallet = wallets.primaryIndex.getOne(walletId)! as LeaderWallet;
    var i = 0;
    for (var address in addresses.byWalletExposure.getAll(walletId, exposure)) {
      if (histories.byScripthash.getAll(address.scripthash).isEmpty) {
        var net = accounts.primaryIndex.getOne(leaderWallet.accountId)!.net;
        return leaderWallet.deriveWallet(net, i, exposure);
        //return leaderWallet.deriveWallet(i, exposure); // service
      }
      i = i + 1;
    }
    // this shouldn't happen - if so we should trigger a new batch??
    var net = accounts.primaryIndex.getOne(leaderWallet.accountId)!.net;
    return leaderWallet.deriveWallet(net, i, exposure);
  }
}
