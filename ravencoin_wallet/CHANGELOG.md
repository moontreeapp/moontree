## 1.2.0

- Change Wallet.seed to be Uint8List; add Wallet.seedHex to get `String?` variant

## 1.1.0

- Null safety
- Use const NetworkType
- ECPair.fromWIF now supports multiple networks (pass in `networks: bitcoinNetworks` to override default `ravencoinNetworks`)

## 1.0.0

- Initial release; a fork of [bitcoin_flutter](https://github.com/dart-bitcoin/bitcoin_flutter) but with ravencoin network parameters

