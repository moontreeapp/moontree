import 'package:raven_back/records/records.dart';

Map<String, Asset> get assets => {
      '0': Asset(
          symbol: 'MOONTREE',
          satsInCirculation: 1000,
          precision: 0,
          reissuable: true,
          metadata: 'metadata',
          txId: '10',
          position: 2)
    };
