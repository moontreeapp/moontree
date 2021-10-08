import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Balance> balances() => MapSource({
      '0': Balance(
          walletId: '0', security: RVN, confirmed: 1500, unconfirmed: 1000),
      '1':
          Balance(walletId: '0', security: USD, confirmed: 100, unconfirmed: 0),
    });
