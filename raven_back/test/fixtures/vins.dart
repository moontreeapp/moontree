import 'package:raven_back/records/records.dart';

Map<String, Vin> get vins => {
      '0': Vin(
          transactionId: '0',
          voutTransactionId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          voutPosition: 0),
      '1': Vin(transactionId: '1', voutTransactionId: '1', voutPosition: 0),
      '2': Vin(transactionId: '2', voutTransactionId: '2', voutPosition: -1),
      '3': Vin(
          transactionId: '3',
          voutTransactionId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          voutPosition: 1),
    };
