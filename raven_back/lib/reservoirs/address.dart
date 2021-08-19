import 'package:raven/records.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class AddressLocation {
  int index;
  NodeExposure exposure;

  AddressLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir extends Reservoir<String, Address> {
  late MultipleIndex byAccount;
  late MultipleIndex byWallet;
  late MultipleIndex byWalletExposure;

  AddressReservoir([source])
      : super(source ?? HiveSource('addresses'),
            (address) => address.scripthash) {
    byAccount = addMultipleIndex('account', (address) => address.accountId);
    byWallet = addMultipleIndex('wallet', (address) => address.walletId);
    byWalletExposure = addMultipleIndex('wallet-exposure',
        (address) => '${address.walletId}:${address.exposure}');
  }

  /// returns account addresses in order
  AddressLocation? getAddressLocationOf(String scripthash, String accountId) {
    var i = 0;
    for (var address
        in byWalletExposure.getAll('$accountId:${NodeExposure.Internal}')) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address
        in byWalletExposure.getAll('$accountId:${NodeExposure.External}')) {
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
