import 'package:raven/records.dart' as records;
import 'package:raven/models/address.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class AddressLocation {
  int index;
  records.NodeExposure exposure;

  AddressLocation(int locationIndex, records.NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir extends Reservoir<String, records.Address, Address> {
  late MultipleIndex byAccount;
  late MultipleIndex byWallet;
  late MultipleIndex byWalletExposure;

  AddressReservoir() : super(HiveSource('addresses')) {
    addPrimaryIndex((address) => address.scripthash);
    byAccount = addMultipleIndex('account', (address) => address.accountId);
    byWallet = addMultipleIndex('wallet', (address) => address.walletId);
    byWalletExposure = addMultipleIndex('wallet-exposure',
        (address) => '${address.walletId}:${address.exposure}');
  }

  /// returns account addresses in order
  AddressLocation? getAddressLocationOf(String scripthash, String accountId) {
    var i = 0;
    for (var address in byWalletExposure
        .getAll('$accountId:${records.NodeExposure.Internal}')) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, records.NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address in byWalletExposure
        .getAll('$accountId:${records.NodeExposure.External}')) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, records.NodeExposure.External);
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
