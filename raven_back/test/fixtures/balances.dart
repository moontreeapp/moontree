import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Balance> balances() => MapSource({
      '0':
          Balance(accountId: 'a0', security: RVN, confirmed: 5, unconfirmed: 0),
      '1':
          Balance(accountId: 'a0', security: USD, confirmed: 1, unconfirmed: 0),
    });
