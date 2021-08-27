import 'package:ordered_set/ordered_set.dart';
import 'package:raven/records.dart';
import 'package:reservoir/reservoir.dart';

part 'address.keys.dart';

class AddressLocation {
  int index;
  NodeExposure exposure;

  AddressLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir extends Reservoir<_ScripthashKey, Address> {
  late IndexMultiple<_AccountKey, Address> byAccount;
  late IndexMultiple<_WalletKey, Address> byWallet;
  late IndexMultiple<_WalletExposureKey, Address> byWalletExposure;

  AddressReservoir([source])
      : super(source ?? HiveSource('addresses'), _ScripthashKey()) {
    byAccount = addIndexMultiple('account', _AccountKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byWalletExposure =
        addIndexMultiple('wallet-exposure', _WalletExposureKey());
  }

  /// returns account addresses in order
  AddressLocation? getAddressLocationOf(String scripthash, String walletId) {
    var i = 0;
    for (var address
        in byWalletExposure.getAll(walletId, NodeExposure.Internal)) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address
        in byWalletExposure.getAll(walletId, NodeExposure.External)) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, NodeExposure.External);
      }
      i = i + 1;
    }
  }

  void removeAddresses(String accountId) {
    byAccount
        .getAll(accountId)
        .forEach((address) => primaryIndex.remove(address));
  }
}
