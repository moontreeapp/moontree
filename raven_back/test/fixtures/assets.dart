import 'package:raven_back/records/records.dart';

Map<String, Asset> get assets => {
      '0': Asset(
          symbol: 'MOONTREE',
          satsInCirculation: 1000,
          divisibility: 0,
          reissuable: true,
          metadata: 'metadata',
          transactionId: '10',
          position: 2),
      '1': Asset(
          symbol: 'MOONTREE1',
          satsInCirculation: 1000,
          divisibility: 2,
          reissuable: true,
          metadata: 'metadata',
          transactionId: '10',
          position: 0)
    };
