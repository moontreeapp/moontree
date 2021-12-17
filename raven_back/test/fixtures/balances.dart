import 'package:raven_back/globals.dart';

import 'package:raven_back/records/records.dart';

Map<String, Balance> get balances => {
      'balance 0': Balance(
          walletId: 'wallet 0',
          security: securities.RVN,
          confirmed: 15000000,
          unconfirmed: 10000000),
      'balance 1': Balance(
          walletId: 'wallet 0',
          security: securities.USD,
          confirmed: 100,
          unconfirmed: 0),
    };
