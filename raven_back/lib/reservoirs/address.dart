import 'package:ordered_set/ordered_set.dart';
import 'package:raven/models/address.dart';
import 'package:raven/records/node_exposure.dart';
import 'package:raven/reservoir/reservoir.dart';

class AddressLocation {
  int index;
  NodeExposure exposure;

  AddressLocation(int locationIndex, NodeExposure locationExposure)
      : index = locationIndex,
        exposure = locationExposure;
}

class AddressReservoir<Record, Model> extends Reservoir {
  AddressReservoir(source, getPrimaryKey, [mapToModel, mapToRecord])
      : super(source, getPrimaryKey, [mapToModel, mapToRecord]) {
    addIndex('account', (address) => address.accountId);
    addIndex('account-exposure',
        (address) => '${address.accountId}:${address.exposure}');
  }

  /// returns account addresses in order
  OrderedSet<Address>? byAccountAndExposure(
      String accountId, NodeExposure exposure) {
    return indices['account-exposure']!.getAll('$accountId:$exposure')
        as OrderedSet<Address>;
  }

  /// returns account addresses in order
  OrderedSet<Address>? byAccount(String accountId) {
    return indices['account']!.getAll(accountId) as OrderedSet<Address>;
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
    byAccount(accountId)!.forEach((address) => remove(address));
  }
}
