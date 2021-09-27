## 2.1.0

- Change default transaction version to 1 when using TransactionBuilder
- Follow modern Dart suggested syntax for TransactionBuilder

## 2.0.1
- Export WalletBase

## 2.0.0
- Network name changes:
  - ravencoinNetworks => networks
  - ravencoin => mainnet
  - bitcoin => bitcoinMainnet
- Wallet is now KPWallet
- Both KPWallet and HDWallet derive from common WalletBase
- HDWallet bip32 and p2pkh are non-nullable

## 1.2.0

- Change Wallet.seed to be Uint8List; add Wallet.seedHex to get `String?` variant

## 1.1.0

- Null safety
- Use const NetworkType
- ECPair.fromWIF now supports multiple networks (pass in `networks: bitcoinNetworks` to override default `ravencoinNetworks`)

## 1.0.0

- Initial release; a fork of [bitcoin_flutter](https://github.com/dart-bitcoin/bitcoin_flutter) but with ravencoin network parameters

