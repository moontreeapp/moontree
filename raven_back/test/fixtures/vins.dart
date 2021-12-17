import 'package:raven_back/records/records.dart';

Map<String, Vin> get vins => {
      '0': Vin(
          txId: '0',
          voutTxId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          voutPosition: 0),
      '1': Vin(txId: '1', voutTxId: '1', voutPosition: 0),
      '2': Vin(txId: '2', voutTxId: '2', voutPosition: -1),
      '3': Vin(
          txId: '3',
          voutTxId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          voutPosition: 1),
    };
