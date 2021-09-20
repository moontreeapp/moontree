import 'package:raven/raven.dart';
import 'package:raven_mobile/utils/transform.dart';

/// a map for human readable wallet types

Map walletMap() =>
    {'HD Wallet': LeaderWallet, 'Private Key Wallet': SingleWallet};

Type walletType(String wallet) => walletMap()[wallet] ?? Wallet;

String walletKind(Wallet wallet) =>
    reverseMap(walletMap())[wallet.runtimeType] ?? 'Wallet';

Function walletCreation(String wallet) =>
    {
      'HD Wallet': (String accountId, {required String secret}) =>
          leaderWalletGenerationService.makeSaveLeaderWallet(accountId, cipher,
              mnemonic: secret),
      'Private Key Wallet': (String accountId, {required String secret}) =>
          singleWalletGenerationService.makeSaveSingleWallet(accountId, cipher,
              wif: secret)
    }[wallet] ??
    (String accountId, {required String secret}) =>
        throw Exception('what kind of wallet is this? $wallet');

String walletSecret(Wallet wallet) =>
    {
      LeaderWallet: EncryptedEntropy(wallet.encrypted, cipher).secret,
      SingleWallet: EncryptedWIF(wallet.encrypted, cipher).secret
    }[wallet.runtimeType] ??
    '';
