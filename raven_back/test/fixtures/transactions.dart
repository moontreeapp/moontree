import 'package:raven_back/records/records.dart';

Map<String, Transaction> get transactions => {
      '0': Transaction(
        txId:
            'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
        confirmed: true,
        height: 0,
      ),
      '1': Transaction(
        txId: '1',
        confirmed: true,
        height: 1,
      ),
      '2': Transaction(
        txId: '2',
        confirmed: true,
        height: 2,
      ),
      '3': Transaction(
        txId:
            'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
        confirmed: true,
        height: 2,
      ),
    };
