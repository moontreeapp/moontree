import 'package:reservoir/map_source.dart';

import 'package:raven/records/records.dart';

MapSource<Balance> balances() => MapSource({
      '0': Balance(walletId: '0', security: RVN, confirmed: 15, unconfirmed: 0),
      '1': Balance(walletId: '0', security: USD, confirmed: 1, unconfirmed: 0),
    });
