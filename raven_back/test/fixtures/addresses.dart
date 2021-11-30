import 'package:reservoir/map_source.dart';

import 'package:raven_back/records/records.dart';

MapSource<Address> addresses() => MapSource({
      'abc0': Address(
          addressId: 'abc0',
          address: 'abc0address',
          walletId: '0',
          hdIndex: 0,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc1': Address(
          addressId: 'abc1',
          address: 'abc1address',
          walletId: '0',
          hdIndex: 1,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc2': Address(
          addressId: 'abc2',
          address: 'abc2address',
          walletId: '0',
          hdIndex: 2,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc3': Address(
          addressId: 'abc3',
          address: 'abc3address',
          walletId: '0',
          hdIndex: 3,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc100': Address(
          addressId: 'abc100',
          address: 'abc100address',
          walletId: '0',
          hdIndex: 3,
          exposure: NodeExposure.External,
          net: Net.Test),
    });
