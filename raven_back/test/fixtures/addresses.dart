import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Address> addresses() => MapSource({
      'abc0': Address(
          scripthash: 'abc0',
          address: 'abc0address',
          walletId: '0',
          hdIndex: 0,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc1': Address(
          scripthash: 'abc1',
          address: 'abc1address',
          walletId: '0',
          hdIndex: 1,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc2': Address(
          scripthash: 'abc2',
          address: 'abc2address',
          walletId: '0',
          hdIndex: 2,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc3': Address(
          scripthash: 'abc3',
          address: 'abc3address',
          walletId: '0',
          hdIndex: 3,
          exposure: NodeExposure.External,
          net: Net.Test),
      'abc100': Address(
          scripthash: 'abc100',
          address: 'abc100address',
          walletId: '0',
          hdIndex: 3,
          exposure: NodeExposure.External,
          net: Net.Test),
    });
