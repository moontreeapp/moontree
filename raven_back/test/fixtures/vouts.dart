import 'package:raven_back/records/records.dart';

Map<String, Vout> get vouts => {
      '0': Vout(
          txId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          rvnValue: 5000000,
          position: 0,
          type: 'pubkeyhash',
          toAddress: 'address 0 address',
          memo: '',
          assetSecurityId: 'RVN:Crypto',
          assetValue: null,
          additionalAddresses: null),
      '1': Vout(
          txId: '1',
          rvnValue: 0,
          position: 0,
          type: 'transfer_asset',
          toAddress: 'address 1 address',
          memo: '',
          assetSecurityId: 'MOONTREE:RavenAsset',
          assetValue: 100,
          additionalAddresses: null),
      '2': Vout(
          txId: '2',
          rvnValue: 10000000,
          position: -1,
          type: 'pubkeyhash',
          toAddress: 'address 2 address',
          memo: '',
          assetSecurityId: 'RVN:Crypto',
          assetValue: null,
          additionalAddresses: null),
      '3': Vout(
          txId:
              'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
          rvnValue: 10000000,
          position: 1,
          type: 'pubkeyhash',
          toAddress: 'address 3 address',
          memo: '',
          assetSecurityId: 'RVN:Crypto',
          assetValue: null,
          additionalAddresses: null),
    };
