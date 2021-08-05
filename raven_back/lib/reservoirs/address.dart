import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/index.dart';
import 'package:raven/reservoir/reservoir.dart';

class AddressLocation {
  int index;
  NodeExposure exposure;

  AddressLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir<Record, Model> extends Reservoir {
  late MultipleIndex byAccount;
  late MultipleIndex byAccountExposure;

  AddressReservoir() : super(HiveSource('addresses')) {
    addPrimaryIndex((address) => address.scripthash);
    byAccount = addMultipleIndex('account', (address) => address.accountId);
    byAccountExposure = addMultipleIndex('account-exposure',
        (address) => '${address.accountId}:${address.exposure}');
  }

  /// returns account addresses in order
  OrderedSet<Address>? byAccountAndExposure(
      String accountId, NodeExposure exposure) {
    return byAccountExposure.getAll('$accountId:$exposure')
        as OrderedSet<Address>;
  }

  AddressLocation? getAddressLocationOf(String scripthash, String accountId) {
    var i = 0;
    for (var address
        in byAccountAndExposure(accountId, NodeExposure.Internal)!) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, NodeExposure.Internal);
      }
      i = i + 1;
    }
    i = 0;
    for (var address
        in byAccountAndExposure(accountId, NodeExposure.External)!) {
      if (address.scripthash == scripthash) {
        return AddressLocation(i, NodeExposure.External);
      }
      i = i + 1;
    }
  }

  void removeAddresses(String accountId) {
    byAccount.getAll(accountId).forEach((address) => remove(address));
  }
}
