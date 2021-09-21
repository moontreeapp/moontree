import 'wallet/leader.dart';
import 'wallet/single.dart';

import 'package:raven/utils/transform.dart';
import 'package:raven/raven.dart';

class WalletService {
  final LeaderWalletService leaders = LeaderWalletService();
  final SingleWalletService singles = SingleWalletService();

  Set<CipherUpdate> get getCurrentCipherUpdates =>
      wallets.data.map((wallet) => wallet.cipherUpdate).toSet();

  Future createSave({
    required LingoKey humanTypeKey,
    required String accountId,
    required CipherUpdate cipherUpdate,
    required String secret,
  }) async =>
      {
        LeaderWallet: () async => await leaders.makeSaveLeaderWallet(
            accountId, cipherRegistry.ciphers[cipherUpdate]!,
            cipherUpdate: cipherUpdate, mnemonic: secret),
        SingleWallet: () async => await singles.makeSaveSingleWallet(
            accountId, cipherRegistry.ciphers[cipherUpdate]!,
            cipherUpdate: cipherUpdate, wif: secret)
      }[walletType(humanTypeKey)]!();

  Map walletMap() => {
        LeaderWallet: LingoKey.leaderWalletType,
        SingleWallet: LingoKey.singleWalletType
      };

  Type walletType(LingoKey humanTypeKey) =>
      reverseMap(walletMap())[humanTypeKey] ?? Wallet;
}
