import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_back/records/records.dart';
import 'package:ravencoin_back/security/cipher_none.dart';

class FixtureSet {
  Map<String, Address> get addresses => {};
  Map<String, Asset> get assets => {};
  Map<String, Balance> get balances => {};
  Map<String, Block> get blocks => {};
  Map<String, Cipher> get ciphers => {};
  Map<String, Metadata> get metadatas => {};
  Map<String, Password> get passwords => {};
  Map<String, Rate> get rates => {};
  Map<String, Security> get securities => {};
  Map<String, Setting> get settings => {};
  Map<String, Transaction> get transactions => {};
  Map<String, Vin> get vins => {};
  Map<String, Vout> get vouts => {};
  Map<String, Wallet> get wallets => {};
}

class FixtureSet0 extends FixtureSet {}

class FixtureSet1 extends FixtureSet {
  @override
  Map<String, Address> get addresses => {
        '0': Address(
            scripthash: '0',
            address: 'address 0 address',
            walletId: '0',
            hdIndex: 0,
            exposure: NodeExposure.internal,
            chain: Chain.ravencoin,
            net: Net.test),
        '1': Address(
            scripthash: '1',
            address: 'address 1 address',
            walletId: '0',
            hdIndex: 1,
            exposure: NodeExposure.external,
            chain: Chain.ravencoin,
            net: Net.test),
        '2': Address(
            scripthash: '2',
            address: 'address 2 address',
            walletId: '0',
            hdIndex: 2,
            exposure: NodeExposure.external,
            chain: Chain.ravencoin,
            net: Net.test),
        '3': Address(
            scripthash: '3',
            address: 'address 3 address',
            walletId: '0',
            hdIndex: 3,
            exposure: NodeExposure.external,
            chain: Chain.ravencoin,
            net: Net.test),
        '100': Address(
            scripthash: '100',
            address: 'address 1 address',
            walletId: '0',
            hdIndex: 3,
            exposure: NodeExposure.external,
            chain: Chain.ravencoin,
            net: Net.test),
      };

  @override
  Map<String, Asset> get assets => {
        '0': Asset(
            chain: Chain.ravencoin,
            net: Net.test,
            symbol: 'MOONTREE',
            satsInCirculation: 1000,
            divisibility: 0,
            reissuable: true,
            metadata: 'metadata',
            transactionId: '10',
            position: 2),
        '1': Asset(
            chain: Chain.ravencoin,
            net: Net.test,
            symbol: 'MOONTREE1',
            satsInCirculation: 1000,
            divisibility: 2,
            reissuable: true,
            metadata: 'metadata',
            transactionId: '10',
            position: 0)
      };

  @override
  Map<String, Balance> get balances => {
        '0': Balance(
            walletId: '0',
            confirmed: 15000000,
            unconfirmed: 10000000,
            security:
                Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test)),
        '1': Balance(
            walletId: '0',
            confirmed: 100,
            unconfirmed: 0,
            security:
                Security(symbol: 'USD', chain: Chain.none, net: Net.test)),
      };

  @override
  Map<String, Block> get blocks => {
        '0': Block(height: 0),
        '1': Block(height: 1),
      };

  @override
  Map<String, Cipher> get ciphers => {
        '0': Cipher(
            cipherType: CipherType.none, passwordId: 0, cipher: CipherNone())
      };

  @override
  Map<String, Metadata> get metadatas => {
        Metadata.key('MOONTREE', 'metadata', Chain.ravencoin, Net.test):
            Metadata(
                chain: Chain.ravencoin,
                net: Net.test,
                symbol: 'MOONTREE',
                metadata: 'metadata',
                data: null,
                kind: MetadataType.unknown,
                parent: null,
                logo: false)
      };

  @override
  Map<String, Password> get passwords =>
      {'0': Password(id: 0, saltedHash: 'saltedHash')};
  @override
  Map<String, Rate> get rates => {
        'RVN:Crypto:USD:Fiat': Rate(
            base:
                Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test),
            quote: Security(symbol: 'USD', chain: Chain.none, net: Net.test),
            rate: .1),
        'MOONTREE:RavenAsset:RVN:Crypto': Rate(
            base: Security(
                symbol: 'MOONTREE', chain: Chain.ravencoin, net: Net.test),
            quote:
                Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test),
            rate: 100),
      };

  @override
  Map<String, Security> get securities => {
        'RVN:Crypto':
            Security(symbol: 'RVN', chain: Chain.ravencoin, net: Net.test),
        'USD:Fiat': Security(symbol: 'USD', chain: Chain.none, net: Net.test),
        'MOONTREE:RavenAsset':
            Security(symbol: 'MOONTREE', chain: Chain.ravencoin, net: Net.test),
      };

  @override
  Map<String, Setting> get settings => {
        'send_immediate':
            Setting(name: SettingName.send_immediate, value: true),
        'user_name':
            Setting(name: SettingName.user_name, value: 'Satoshi Nakamoto'),
      };

  @override
  Map<String, Transaction> get transactions => {
        '0': Transaction(
            id: 'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            confirmed: true,
            height: 0),
        '1': Transaction(id: '1', confirmed: true, height: 1),
        '2': Transaction(id: '2', confirmed: true, height: 2),
        '3': Transaction(
            id: 'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            confirmed: true,
            height: 2),
      };

  @override
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

  @override
  Map<String, Vout> get vouts => {
        '0': Vout(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            coinValue: 5000000,
            position: 0,
            type: 'pubkeyhash',
            toAddress: 'address 0 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null), // spent
        '1': Vout(
            transactionId: '1',
            coinValue: 0,
            position: 0,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE:RavenAsset',
            assetValue: 100,
            additionalAddresses: null), // claimed by a Vin
        '2': Vout(
            transactionId: '1',
            coinValue: 0,
            position: 99,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE:RavenAsset',
            assetValue: 100,
            additionalAddresses: null), // not consumed
        '3': Vout(
            transactionId: '2',
            coinValue: 10000000,
            position: -1,
            type: 'pubkeyhash',
            toAddress: 'address 2 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null), // spent
        '4': Vout(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            coinValue: 10000000,
            position: 1,
            type: 'pubkeyhash',
            toAddress: 'address 3 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null), // spent
        '5': Vout(
            transactionId: '10',
            coinValue: 0,
            position: 0,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE0:RavenAsset',
            assetValue: 100,
            additionalAddresses: null), // consumed?
        '6': Vout(
            transactionId: '1',
            coinValue: 0,
            position: 100,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE:RavenAsset',
            assetValue: 1000,
            additionalAddresses: null), // not consumed
        '7': Vout(
            transactionId: '1',
            coinValue: 0,
            position: 101,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE:RavenAsset',
            assetValue: 500,
            additionalAddresses: null), // not consumed
        '8': Vout(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            coinValue: 5000000,
            position: 11,
            type: 'pubkeyhash',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null), // unspent
        '9': Vout(
            transactionId: '2',
            coinValue: 10000000,
            position: -10,
            type: 'pubkeyhash',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null), // unspent
        '10': Vout(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            coinValue: 10000000,
            position: 10,
            type: 'pubkeyhash',
            toAddress: 'address 0 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null), // unspent
      };

  @override
  Map<String, Wallet> get wallets {
    dotenv.load();
    var phrase = dotenv.env['TEST_WALLET_01']!;
    return {
      '0': LeaderWallet(
          id: '0',
          cipherUpdate: CipherUpdate(CipherType.none),
          encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
      // has no addresses
      '1': LeaderWallet(
          id: '1',
          cipherUpdate: CipherUpdate(CipherType.none),
          encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
      '2': LeaderWallet(
          id: '2',
          cipherUpdate: CipherUpdate(CipherType.none),
          encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
    };
  }
}
