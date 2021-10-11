import 'package:reservoir/map_source.dart';

import 'package:raven/records/history.dart';
import 'package:raven/records/security.dart';

import 'package:raven/records/records.dart';

MapSource<History> histories() => MapSource({
      '0': History(
          hash:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          scripthash: 'abc0',
          height: 0,
          security: RVN,
          position: 0,
          value: 5000000),
      '1': History(
          hash: '1',
          scripthash: 'abc1',
          height: 1,
          security: USD,
          position: 0,
          value: 100),
      '2': History(
          hash: '2',
          scripthash: 'abc2',
          height: 2,
          security: RVN,
          position: -1,
          value: 10000000),
      '3': History(
          hash:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          scripthash: 'abc3',
          height: 2,
          security: RVN,
          position: 1,
          value: 10000000),
    });
