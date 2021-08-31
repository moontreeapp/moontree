import 'package:raven/records/history.dart';
import 'package:raven/records/security.dart';

Map<String, History> histories = {
  '0': History(
      scripthash: '0',
      accountId: 'a1',
      walletId: 'w1',
      height: 0,
      hash: '0',
      security: RVN),
  '1': History(
      scripthash: '1',
      accountId: 'a1',
      walletId: 'w1',
      height: 1,
      hash: '0',
      security: USD),
  '2': History(
      scripthash: '2',
      accountId: 'a2',
      walletId: 'w2',
      height: 2,
      hash: '0',
      security: RVN),
};
