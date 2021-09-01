import 'package:reservoir/map_source.dart';

import 'package:raven/records/history.dart';
import 'package:raven/records/security.dart';

import 'package:raven/records/records.dart';

MapSource<History> histories() => MapSource({
      '0': History(
          hash: '0',
          scripthash: 'abc0',
          accountId: 'a0',
          walletId: 'w0',
          height: 0,
          security: RVN,
          position: 0,
          value: 5),
      '1': History(
          hash: '1',
          scripthash: 'abc1',
          accountId: 'a0',
          walletId: 'w0',
          height: 1,
          security: USD,
          position: 0,
          value: 1),
      '2': History(
          hash: '2',
          scripthash: 'abc2',
          accountId: 'a1',
          walletId: 'w2',
          height: 2,
          security: RVN,
          position: -1,
          value: 10),
      '3': History(
          hash: '3',
          scripthash: 'abc3',
          accountId: 'a0',
          walletId: 'w2',
          height: 2,
          security: RVN,
          position: 1,
          value: 10),
    });
