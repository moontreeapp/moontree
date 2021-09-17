import 'package:raven/raven.dart';
import 'package:raven_mobile/utils/transform.dart';

/// a map for human readable wallet types

Map walletMap() =>
    {'HD Wallet': LeaderWallet, 'Private Key Wallet': SingleWallet};

Type walletType(String wallet) => walletMap()[wallet] ?? Wallet;

String walletKind(Wallet wallet) => reverseMap(walletMap())[wallet] ?? 'Wallet';

Function walletCreation(String wallet) =>
    {
      'HD Wallet': (String accountId, {required String secret}) =>
          leaderWalletGenerationService.makeSaveLeaderWallet(accountId,
              mnemonic: secret),
      'Private Key Wallet': (String accountId, {required String secret}) =>
          singleWalletGenerationService.makeSaveSingleWallet(accountId,
              wif: secret)
    }[wallet] ??
    (String accountId, {required String secret}) =>
        throw Exception('what kind of wallet is this? $wallet');
