import 'package:raven_back/globals.dart';
import 'package:reservoir/map_source.dart';

import 'package:raven_back/records/records.dart';

MapSource<Balance> balances() => MapSource({
      '0': Balance(
          walletId: '0',
          security: securities.RVN,
          confirmed: 15000000,
          unconfirmed: 10000000),
      '1': Balance(
          walletId: '0',
          security: securities.USD,
          confirmed: 100,
          unconfirmed: 0),
    });
