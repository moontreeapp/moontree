import 'package:reservoir/map_source.dart';

import 'package:raven_back/records/vout.dart';

import 'package:raven_back/records/records.dart';

import 'securities.dart';

// TODO: change this to vins and vouts?
MapSource<History> histories() => MapSource({
      '0': History(
          txId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          addressId: 'abc0',
          height: 0,
          security: RVN,
          position: 0,
          value: 5000000),
      '1': History(
          txId: '1',
          addressId: 'abc1',
          height: 1,
          security: USD,
          position: 0,
          value: 100),
      '2': History(
          txId: '2',
          addressId: 'abc2',
          height: 2,
          security: RVN,
          position: -1,
          value: 10000000),
      '3': History(
          txId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          addressId: 'abc3',
          height: 2,
          security: RVN,
          position: 1,
          value: 10000000),
    });
