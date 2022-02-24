import 'package:collection/collection.dart';
import 'package:reservoir/reservoir.dart';
import 'package:raven_back/raven_back.dart';

part 'address.keys.dart';

class AddressLocation {
  int index;
  NodeExposure exposure;

  AddressLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir extends Reservoir<_ScripthashKey, Address> {
  late IndexMultiple<_AddressKey, Address> byAddress;
  late IndexMultiple<_WalletKey, Address> byWallet;
  late IndexMultiple<_WalletExposureKey, Address> byWalletExposure;

  AddressReservoir() : super(_ScripthashKey()) {
    byAddress = addIndexMultiple('address', _AddressKey());
    byWallet = addIndexMultiple('wallet', _WalletKey());
    byWalletExposure =
        addIndexMultiple('wallet-exposure', _WalletExposureKey());
  }

  /// returns addresses in order
  AddressLocation? getAddressLocationOf(String addressId, String walletId) {
    var i = 0;
    for (var address
        in byWalletExposure.getAll(walletId, NodeExposure.Internal)) {
      if (address.id == addressId) {
        return AddressLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address
        in byWalletExposure.getAll(walletId, NodeExposure.External)) {
      if (address.id == addressId) {
        return AddressLocation(i, NodeExposure.External);
      }
      i = i + 1;
    }
  }

  void removeAddresses(Wallet wallet) {
    wallet.addresses.forEach((Address address) => primaryIndex.remove(address));
  }
}
