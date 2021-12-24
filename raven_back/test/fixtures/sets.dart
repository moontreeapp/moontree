import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven_back/records/records.dart';
import 'package:raven_back/security/cipher_none.dart';

class FixtureSet {
  static Map<String, Account> get accounts => {};
  static Map<String, Address> get addresses => {};
  static Map<String, Asset> get assets => {};
  static Map<String, Balance> get balances => {};
  static Map<String, Block> get blocks => {};
  static Map<String, Cipher> get ciphers => {};
  static Map<String, Metadata> get metadatas => {};
  static Map<String, Password> get passwords => {};
  static Map<String, Rate> get rates => {};
  static Map<String, Security> get securities => {};
  static Map<String, Setting> get settings => {};
  static Map<String, Transaction> get transactions => {};
  static Map<String, Vin> get vins => {};
  static Map<String, Vout> get vouts => {};
  static Map<String, Wallet> get wallets => {};
}

class FixtureSet0 extends FixtureSet {}

class FixtureSet1 extends FixtureSet {
  static Map<String, Account> get accounts => {
        '0': Account(name: 'Account 0', accountId: '0', net: Net.Main),
        '1': Account(name: 'Account 1', accountId: '1', net: Net.Test),
      };
  static Map<String, Address> get addresses => {
        '0': Address(
            addressId: '0',
            address: 'address 0 address',
            walletId: '0',
            hdIndex: 0,
            exposure: NodeExposure.Internal,
            net: Net.Test),
        '1': Address(
            addressId: '1',
            address: 'address 1 address',
            walletId: '0',
            hdIndex: 1,
            exposure: NodeExposure.External,
            net: Net.Test),
        '2': Address(
            addressId: '2',
            address: 'address 2 address',
            walletId: '0',
            hdIndex: 2,
            exposure: NodeExposure.External,
            net: Net.Test),
        '3': Address(
            addressId: '3',
            address: 'address 3 address',
            walletId: '0',
            hdIndex: 3,
            exposure: NodeExposure.External,
            net: Net.Test),
        '100': Address(
            addressId: '0',
            address: 'address 1 address',
            walletId: '0',
            hdIndex: 3,
            exposure: NodeExposure.External,
            net: Net.Test),
      };
  static Map<String, Asset> get assets => {
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
  static Map<String, Balance> get balances => {
        '0': Balance(
            walletId: '0',
            confirmed: 15000000,
            unconfirmed: 10000000,
            security:
                Security(symbol: 'RVN', securityType: SecurityType.Crypto)),
        '1': Balance(
            walletId: '0',
            confirmed: 100,
            unconfirmed: 0,
            security: Security(symbol: 'USD', securityType: SecurityType.Fiat)),
      };
  static Map<String, Block> get blocks => {
        '0': Block(height: 0),
        '1': Block(height: 1),
      };
  static Map<String, Cipher> get ciphers => {
        '0': Cipher(
            cipherType: CipherType.None, passwordId: 0, cipher: CipherNone())
      };
  static Map<String, Metadata> get metadatas => {
        Metadata.metadataKey('MOONTREE', 'metadata'): Metadata(
            symbol: 'MOONTREE',
            metadata: 'metadata',
            data: null,
            kind: MetadataType.Unknown,
            parent: null,
            logo: false)
      };
  static Map<String, Password> get passwords =>
      {'0': Password(passwordId: 0, saltedHash: 'saltedHash')};
  static Map<String, Rate> get rates => {
        'RVN:Crypto:USD:Fiat': Rate(
            base: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
            quote: Security(symbol: 'USD', securityType: SecurityType.Fiat),
            rate: .1),
        'MOONTREE:RavenAsset:RVN:Crypto': Rate(
            base: Security(
                symbol: 'MOONTREE', securityType: SecurityType.RavenAsset),
            quote: Security(symbol: 'RVN', securityType: SecurityType.Crypto),
            rate: 100),
      };
  static Map<String, Security> get securities => {
        'RVN:Crypto':
            Security(symbol: 'RVN', securityType: SecurityType.Crypto),
        'USD:Fiat': Security(symbol: 'USD', securityType: SecurityType.Fiat),
        'MOONTREE:RavenAsset':
            Security(symbol: 'MOONTREE', securityType: SecurityType.RavenAsset),
      };
  static Map<String, Setting> get settings => {
        'Send_Immediate':
            Setting(name: SettingName.Send_Immediate, value: true),
        'User_Name':
            Setting(name: SettingName.User_Name, value: 'Satoshi Nakamoto'),
      };
  static Map<String, Transaction> get transactions => {
        '0': Transaction(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            confirmed: true,
            height: 0),
        '1': Transaction(transactionId: '1', confirmed: true, height: 1),
        '2': Transaction(transactionId: '2', confirmed: true, height: 2),
        '3': Transaction(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            confirmed: true,
            height: 2),
      };

  static Map<String, Vin> get vins => {
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
  static Map<String, Vout> get vouts => {
        '0': Vout(
            transactionId:
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
            transactionId: '1',
            rvnValue: 0,
            position: 0,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE:RavenAsset',
            assetValue: 100,
            additionalAddresses: null),
        '2': Vout(
            transactionId: '2',
            rvnValue: 10000000,
            position: -1,
            type: 'pubkeyhash',
            toAddress: 'address 2 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null),
        '3': Vout(
            transactionId:
                'f01424fdc167dc40acb2f68b330807a839c443a769cc8f95ea0737c852b1a5e6',
            rvnValue: 10000000,
            position: 1,
            type: 'pubkeyhash',
            toAddress: 'address 3 address',
            memo: '',
            assetSecurityId: 'RVN:Crypto',
            assetValue: null,
            additionalAddresses: null),
        '4': Vout(
            transactionId: '10',
            rvnValue: 0,
            position: 0,
            type: 'transfer_asset',
            toAddress: 'address 1 address',
            memo: '',
            assetSecurityId: 'MOONTREE0:RavenAsset',
            assetValue: 100,
            additionalAddresses: null),
      };
  static Map<String, Wallet> get wallets {
    dotenv.load();
    var phrase = dotenv.env['TEST_WALLET_01']!;
    return {
      '0': LeaderWallet(
          walletId: '0',
          accountId: '1',
          cipherUpdate: CipherUpdate(CipherType.None),
          encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
      // has no addresses
      '1': LeaderWallet(
          walletId: '1',
          accountId: '1',
          cipherUpdate: CipherUpdate(CipherType.None),
          encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
      '2': LeaderWallet(
          walletId: '2',
          accountId: '1',
          cipherUpdate: CipherUpdate(CipherType.None),
          encryptedEntropy: bip39.mnemonicToEntropy(phrase)),
    };
  }
}
