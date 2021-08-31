import 'package:reservoir/map_source.dart';

import 'package:raven/records/history.dart';
import 'package:raven/records/security.dart';

import 'package:raven/records/records.dart';

MapSource<History> histories = MapSource({
  '0': History(
      scripthash: '0',
      accountId: 'a0',
      walletId: 'w0',
      height: 0,
      hash: '0',
      security: RVN,
      position: 0,
      value: 5),
  '1': History(
      scripthash: '1',
      accountId: 'a0',
      walletId: 'w0',
      height: 1,
      hash: '1',
      security: USD,
      position: 0,
      value: 1),
  '2': History(
      scripthash: '2',
      accountId: 'a1',
      walletId: 'w2',
      height: 2,
      hash: '2',
      security: RVN,
      position: 0,
      value: 10),
  '3': History(
      scripthash: '3',
      accountId: 'a0',
      walletId: 'w2',
      height: 2,
      hash: '3',
      security: RVN,
      position: 1,
      value: 10),
});
