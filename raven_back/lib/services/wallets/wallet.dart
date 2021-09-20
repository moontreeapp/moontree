import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';
import 'package:raven/services/service.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/transform.dart';

class WalletService extends Service {
  late WalletReservoir wallets;

  WalletService(this.wallets) : super();

  Set<CipherUpdate> get getCurrentCipherUpdates =>
      wallets.data.map((wallet) => wallet.cipherUpdate).toSet();

  Future<void> createSave({
    required String humanType,
    required String accountId,
    required CipherUpdate cipherUpdate,
    required String secret,
  }) async =>
      WalletCreator(
        humanType: humanType,
        accountId: accountId,
        cipherUpdate: cipherUpdate,
        secret: secret,
      ).createSave();
}

class WalletCreator {
  final String humanType;
  final String accountId;
  final CipherUpdate cipherUpdate;
  final String secret;

  WalletCreator({
    required this.humanType,
    required this.accountId,
    required this.cipherUpdate,
    required this.secret,
  });

  Map walletMap() =>
      {LeaderWallet: 'HD Wallet', SingleWallet: 'Private Key Wallet'};

  Type walletType(String wallet) => reverseMap(walletMap())[wallet] ?? Wallet;

  Future<void> createSave() async => {
        LeaderWallet: () async =>
            await leaderWalletGenerationService.makeSaveLeaderWallet(
                accountId, cipherRegistry.ciphers[cipherUpdate]!,
                cipherUpdate: cipherUpdate, mnemonic: secret),
        SingleWallet: () async =>
            await singleWalletGenerationService.makeSaveSingleWallet(
                accountId, cipherRegistry.ciphers[cipherUpdate]!,
                cipherUpdate: cipherUpdate, wif: secret)
      }[walletType(humanType)]!();
}
