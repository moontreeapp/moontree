import 'package:ordered_set/ordered_set.dart';
import 'package:raven/records.dart';
import 'package:raven/reservoir/reservoir.dart';

class AddressLocation {
  int index;
  NodeExposure exposure;

  AddressLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir extends Reservoir<String, Address> {
  late IndexMultiple<String, Address> byAccount;
  late IndexMultiple<String, Address> byWallet;
  late IndexMultiple<String, Address> byWalletExposure;

  AddressReservoir([source])
      : super(source ?? HiveSource('addresses'),
            (address) => address.scripthash) {
    byAccount = addIndexMultiple('account', (address) => address.accountId);
    byWallet = addIndexMultiple('wallet', (address) => address.walletId);
    byWalletExposure = addIndexMultiple('wallet-exposure',
        (address) => '${address.walletId}:${address.exposure}');
  }

  OrderedSet<Address> getByWalletExposure(
      String walletId, NodeExposure exposure) {
    return byWalletExposure.getAll('$walletId:${exposure}');
  }

  /// returns account addresses in order
  AddressLocation? getAddressLocationOf(String scripthash, String walletId) {
    var i = 0;
    for (var address
        in byWalletExposure.getAll('$walletId:${NodeExposure.Internal}')) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address
        in byWalletExposure.getAll('$walletId:${NodeExposure.External}')) {
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
