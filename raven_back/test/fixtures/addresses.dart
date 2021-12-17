import 'package:reservoir/map_source.dart';

import 'package:raven_back/records/records.dart';

Map<String, Address> get addresses => {
      'address 0': Address(
          addressId: 'address 0',
          address: 'address 0 address',
          walletId: 'wallet 0',
          hdIndex: 0,
          exposure: NodeExposure.Internal,
          net: Net.Test),
      'address 1': Address(
          addressId: 'address 1',
          address: 'address 1 address',
          walletId: 'wallet 0',
          hdIndex: 1,
          exposure: NodeExposure.External,
          net: Net.Test),
      'address 2': Address(
          addressId: 'address 2',
          address: 'address 2 address',
          walletId: 'wallet 0',
          hdIndex: 2,
          exposure: NodeExposure.External,
          net: Net.Test),
      'address 3': Address(
          addressId: 'address 3',
          address: 'address 3 address',
          walletId: 'wallet 0',
          hdIndex: 3,
          exposure: NodeExposure.External,
          net: Net.Test),
      'address 100': Address(
          addressId: 'address 0',
          address: 'address 1 address',
          walletId: 'wallet 0',
          hdIndex: 3,
          exposure: NodeExposure.External,
          net: Net.Test),
    };
